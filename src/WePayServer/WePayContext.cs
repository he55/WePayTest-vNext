using Microsoft.EntityFrameworkCore;
using System;
using System.ComponentModel.DataAnnotations.Schema;
using System.Diagnostics.CodeAnalysis;
using System.Threading;
using System.Threading.Tasks;

namespace WePayServer
{
    public class WePayContext : DbContext
    {
        public WePayContext([NotNull] DbContextOptions<WePayContext> options)
            : base(options)
        {
        }

        public DbSet<WePayOrder> WePayOrders { get; set; } = null!;

        /// <inheritdoc />
        public override int SaveChanges(bool acceptAllChangesOnSuccess)
        {
            SetModelBaseValue();
            return base.SaveChanges(acceptAllChangesOnSuccess);
        }

        /// <inheritdoc />
        public override Task<int> SaveChangesAsync(bool acceptAllChangesOnSuccess, CancellationToken cancellationToken = default)
        {
            SetModelBaseValue();
            return base.SaveChangesAsync(acceptAllChangesOnSuccess, cancellationToken);
        }

        private void SetModelBaseValue()
        {
            foreach (var entityEntry in ChangeTracker.Entries())
            {
                if (entityEntry.Entity is ModelBase model)
                {
                    long timestamp = DateTimeOffset.Now.ToUnixTimeMilliseconds();
                    if (entityEntry.State == EntityState.Added)
                    {
                        model.CreateTime = timestamp;
                        model.UpdateTime = timestamp;
                    }
                    else if (entityEntry.State == EntityState.Modified)
                    {
                        model.UpdateTime = timestamp;
                    }
                }
            }
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<WePayOrder>(x =>
            {
                x.ToTable("Order");
                x.HasIndex(m => m.Id).IsUnique();
                x.HasIndex(m => m.OrderId).IsUnique();
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

    public class WePayOrder : ModelBase
    {
        public string OrderId { get; set; } = "";
        public decimal OrderAmount { get; set; }
        public string OrderCode { get; set; } = "";
        public string OrderMessage { get; set; } = "";
        public bool IsPay { get; set; }
        public long PayTime { get; set; }
        [NotMapped]
        public bool IsSend { get; set; }
    }
}
