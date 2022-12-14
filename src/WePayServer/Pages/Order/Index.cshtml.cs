using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;

namespace WePayServer.Pages.Order
{
    public class IndexModel : PageModel
    {
        private readonly WePayContext _context;

        public IndexModel(WePayContext context)
        {
            _context = context;
        }

        public IList<WePayOrder> WePayOrder { get; set; }

        public async Task OnGetAsync()
        {
            WePayOrder = await _context.WePayOrders.ToListAsync();
        }
    }
}
