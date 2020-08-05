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
    }
}
