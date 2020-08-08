using System.Linq;
using System.Threading.Tasks;
using WePayServer.Data;
using WePayServer.Models;
using WePayServer.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;

namespace WePayServer.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class OrderController : ControllerBase
    {
        private readonly WePayContext _context;
        private readonly OrderService _orderService;

        private static readonly List<WePayOrder> WePayOrders = new List<WePayOrder>();

        public OrderController(WePayContext context, OrderService orderService)
        {
            _context = context;
            _orderService = orderService;
        }

        [HttpGet("/pull_order")]
        public ResultModel PullOrder()
        {
            _orderService.RequestExecute();
            return this.ResultSuccess(null, 0, "ok");
        }

        [HttpPost("/wepay")]
        public ActionResult<WePayOrder> WePay(long? sid, string? code)
        {
            if (!string.IsNullOrEmpty(code))
            {
                WePayOrder wePayOrder = WePayOrders.Where(x => x.Id == sid).FirstOrDefault();
                if (wePayOrder != null)
                {
                    wePayOrder.OrderCode = code;
                    WePayOrders.Remove(wePayOrder);
                }
            }

            WePayOrder wePayOrder1 = WePayOrders.Where(x => x.OrderCode == "").FirstOrDefault();
            if (wePayOrder1 != null)
            {
                return wePayOrder1;
            }
            return NoContent();
        }

        [HttpGet("{id:long}")]
        public async Task<ResultModel> GetOrderAsync(long id)
        {
            WePayOrder order = await _context.WePayOrders
                .Where(x => x.Id == id)
                .FirstOrDefaultAsync();
            if (order == null)
            {
                return this.ResultFail("没有找到指定订单");
            }

            if (!order.IsPay)
            {
                _orderService.RequestExecute();
            }

            return this.ResultSuccess(order);
        }

        [HttpPost]
        public async Task<ResultModel> CreateOrderAsync(WePayOrderDto order)
        {
            if (order.OrderAmount < 0.01m)
            {
                return this.ResultFail("参数错误，金额不能小于 0.01 元");
            }

            if (order.OrderId.Length == 0)
            {
                return this.ResultFail("参数错误，订单号长度不能为 0");
            }

            if (await _context.WePayOrders.AnyAsync(x => x.OrderId == order.OrderId))
            {
                return this.ResultFail("订单号已经存在");
            }


            WePayOrder wePayOrder = new WePayOrder
            {
                OrderId = order.OrderId,
                OrderAmount = order.OrderAmount
            };
            _context.WePayOrders.Add(wePayOrder);
            await _context.SaveChangesAsync();

            WePayOrders.Add(wePayOrder);

            for (int i = 0; i < 20; i++)
            {
                await Task.Delay(300);
                if (wePayOrder.OrderCode != "")
                {
                    await _context.SaveChangesAsync();
                    return this.ResultSuccess(wePayOrder);
                }
            }
            return this.ResultFail("订单生成失败");
        }
    }
}
