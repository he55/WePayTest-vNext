using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace WePayServer.Pages.Order
{
    public class IndexModel : PageModel
    {
        private readonly WePayContext _context;

        public IndexModel(WePayContext context)
        {
            _context = context;
        }

        public IList<WePayOrder> Orders { get; set; }

        public async Task OnGetAsync()
        {
            Orders = await _context.WePayOrders.ToListAsync();
        }
    }
}
