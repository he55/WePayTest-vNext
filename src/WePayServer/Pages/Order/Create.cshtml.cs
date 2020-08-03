using System.Threading.Tasks;
using WePayServer.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace WePayServer.Pages.Order
{
    public class CreateModel : PageModel
    {
        private readonly WePayContext _context;

        public CreateModel(WePayContext context)
        {
            _context = context;
        }

        public IActionResult OnGet()
        {
            return Page();
        }

        [BindProperty]
        public WePayOrder WePayOrder { get; set; } = null!;

        // To protect from overposting attacks, enable the specific properties you want to bind to, for
        // more details, see https://aka.ms/RazorPagesCRUD.
        public async Task<IActionResult> OnPostAsync()
        {
            if (!ModelState.IsValid)
            {
                return Page();
            }

            _context.WePayOrders.Add(WePayOrder);
            await _context.SaveChangesAsync();

            return RedirectToPage("./Index");
        }
    }
}
