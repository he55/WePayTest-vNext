using System.Threading.Tasks;
using WePayServer.Data;
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

        [BindProperty]
        public WePayOrder WePayOrder { get; set; } = null!;

        public async Task<IActionResult> OnGetAsync(long? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            WePayOrder = await _context.WePayOrders.FirstOrDefaultAsync(m => m.Id == id);

            if (WePayOrder == null)
            {
                return NotFound();
            }
            return Page();
        }

        public async Task<IActionResult> OnPostAsync(long? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            WePayOrder = await _context.WePayOrders.FindAsync(id);

            if (WePayOrder != null)
            {
                WePayOrder.IsDeleted = true;
                await _context.SaveChangesAsync();
            }
            return RedirectToPage("./Index");
        }
    }
}
