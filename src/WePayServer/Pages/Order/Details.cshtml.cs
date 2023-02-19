using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using System.Threading.Tasks;

namespace WePayServer.Pages.Order
{
    public class DetailsModel : PageModel
    {
        private readonly WePayContext _context;

        public DetailsModel(WePayContext context)
        {
            _context = context;
        }

        public WePayOrder WePayOrder { get; set; }

        public async Task<IActionResult> OnGetAsync(long id)
        {
            WePayOrder = await _context.WePayOrders.FirstOrDefaultAsync(m => m.Id == id);
            if (WePayOrder == null)
            {
                return NotFound();
            }
            return Page();
        }
    }
}
