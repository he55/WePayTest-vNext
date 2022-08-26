using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;

namespace WePayServer.Pages.Order
{
    public class DeleteModel : PageModel
    {
        private readonly WePayContext _context;

        public DeleteModel(WePayContext context)
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

        public async Task<IActionResult> OnPostAsync(long id)
        {
            WePayOrder wePayOrder = await _context.WePayOrders.FindAsync(id);
            if (wePayOrder != null)
            {
                wePayOrder.IsDeleted = true;
                await _context.SaveChangesAsync();
            }
            return RedirectToPage("./Index");
        }
    }
}
