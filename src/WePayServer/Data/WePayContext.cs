using System;
using System.ComponentModel.DataAnnotations.Schema;
using System.Diagnostics.CodeAnalysis;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;

namespace WePayServer.Data
{
    public class WePayContext : DbContext
    {
        public WePayContext([NotNull] DbContextOptions<WePayContext> options)
            : base(options)
        {
        }

        public DbSet<WePayMessage> WePayMessages { get; set; } = null!;
        public DbSet<WePayOrder> WePayOrders { get; set; } = null!;

        /// <inheritdoc />
        public override int SaveChanges(bool acceptAllChangesOnSuccess)
        {
            SetModelBaseTime();
            return base.SaveChanges(acceptAllChangesOnSuccess);
        }

        /// <inheritdoc />
        public override Task<int> SaveChangesAsync(bool acceptAllChangesOnSuccess, CancellationToken cancellationToken = default)
        {
            SetModelBaseTime();
            return base.SaveChangesAsync(acceptAllChangesOnSuccess, cancellationToken);
        }

        private void SetModelBaseTime()
        {
            foreach (var entityEntry in ChangeTracker.Entries())
            {
                if (entityEntry.Entity is ModelBase e)
                {
                    if (entityEntry.State == EntityState.Added)
                    {
                        long timestamp = DateTimeOffset.Now.ToUnixTimeMilliseconds();
                        e.CreateTime = timestamp;
                        e.UpdateTime = timestamp;
                    }
                    else if (entityEntry.State == EntityState.Modified)
                    {
                        e.UpdateTime = DateTimeOffset.Now.ToUnixTimeMilliseconds();
                    }
                }
            }
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<WePayMessage>(x =>
            {
                x.ToTable("WePay_Message");
                x.HasIndex(m => m.Id).IsUnique();
                x.HasIndex(m => m.MessageId).IsUnique();
                x.HasQueryFilter(m => !m.IsDeleted);
            });

            modelBuilder.Entity<WePayOrder>(x =>
            {
                x.ToTable("WePay_Order");
                x.HasIndex(m => m.Id).IsUnique();
                x.HasQueryFilter(m => !m.IsDeleted);
            });
        }
    }

    public class ModelBase
    {
        public long Id { get; set; }
        public long CreateTime { get; set; }
        public long UpdateTime { get; set; }
        public bool IsDeleted { get; set; }
    }

    public class WePayMessage : ModelBase
    {
        public int MessageCreateTime { get; set; }
        public string MessageId { get; set; } = null!;
        public string MessageContent { get; set; } = null!;
        public int MessagePublishTime { get; set; }
        public string OrderId { get; set; } = null!;
        public decimal OrderAmount { get; set; }
    }

    public class WePayOrder : ModelBase
    {
        public string OrderId { get; set; } = "";
        public decimal OrderAmount { get; set; }
        public string OrderCode { get; set; } = "";
        public bool OrderIsPay { get; set; }
    }
}
