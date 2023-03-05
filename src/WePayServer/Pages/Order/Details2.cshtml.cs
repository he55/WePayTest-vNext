using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace WePayServer.Pages.Order
{
    public class Details2Model : PageModel
    {
        private readonly WePayContext _context;

        public Details2Model(WePayContext context)
        {
            _context = context;
        }

        public IList<WePayOrder> Orders { get; set; }

        public async Task OnGetAsync(string id)
        {
            Orders = await _context.WePayOrders
                .Where(x => x.OrderId == id)
                .OrderByDescending(x => x.PayTime)
                .ToListAsync();
        }
    }
}
