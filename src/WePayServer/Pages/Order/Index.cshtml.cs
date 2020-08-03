using System.Collections.Generic;
using System.Threading.Tasks;
using WePayServer.Data;
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

        public IList<WePayOrder> WePayOrder { get; set; } = null!;

        public async Task OnGetAsync()
        {
            WePayOrder = await _context.WePayOrders.ToListAsync();
        }
    }
}
