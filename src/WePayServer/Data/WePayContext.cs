using System;
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
    }
}
