using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace WePayServer.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class OrderController : ControllerBase
    {
        private static readonly List<WePayOrder> Orders = new List<WePayOrder>();

        private readonly WePayContext _context;

        public OrderController(WePayContext context)
        {
            _context = context;
        }

        [HttpGet("/getOrderTask")]
        public List<WePayOrder> GetOrderTask()
        {
            List<WePayOrder> orders = Orders.Where(x => !x.IsSend)
                .OrderBy(x => x.Id)
                .ToList();

            foreach (WePayOrder item in orders)
            {
                item.IsSend = true;
            }

            return orders;
        }

        [HttpPost("/postOrderTask")]
        public ResultModel PostOrderTask(OrderCodeDto orderCodeDto)
        {
            WePayOrder order = Orders.FirstOrDefault(x => x.Id == orderCodeDto.Id);
            if (order != null)
            {
                order.OrderCode = orderCodeDto.OrderCode;
                Orders.Remove(order);
            }

            return this.ResultSuccess();
        }

        [HttpGet("/getLastPayTime")]
        public async Task<long> GetLastPayTime(string orderId)
        {
            WePayOrder order = await _context.WePayOrders.OrderByDescending(x => x.PayTime)
                .FirstOrDefaultAsync(x => x.OrderId == orderId);
            if (order == null)
            {
                return 0;
            }
            return order.PayTime;
        }

        [HttpPost("/postMessage")]
        public async Task<long> PostMessage(List<WePayMessageDto> messageDtos)
        {
            foreach (WePayMessageDto messageDto in messageDtos)
            {
                Dictionary<string, string> messageInfo = WeChatService.GetMessageInfo(messageDto.Message);
                string orderId = messageInfo["detail_content_value_1"];
                if (orderId.EndsWith("!"))
                {
                    int count2 = await _context.WePayOrders.CountAsync(x => x.OrderId == orderId );
                    int count = await _context.WePayOrders.CountAsync(x => x.OrderId == orderId && x.PayTime == messageDto.CreateTime);
                    if (count2==0||count == 0)
                    {
                        WePayOrder order = new WePayOrder
                        {
                            OrderId = orderId,
                            OrderType = 1,
                            IsSub=count2!=0,
                            OrderAmount = -1,
                            IsPay = true,
                            PayTime = messageDto.CreateTime
                        };

                        _context.WePayOrders.Add(order);
                        await _context.SaveChangesAsync();
                    }
                }
                else
                {
                    WePayOrder order = await _context.WePayOrders.FirstOrDefaultAsync(x => x.OrderId == orderId && !x.IsPay);
                    if (order != null)
                    {
                        order.IsPay = true;
                        order.OrderMessage = messageDto.Message;
                        order.PayTime = messageDto.CreateTime;
                        await _context.SaveChangesAsync();
                    }
                }
            }

            if (_context.WePayOrders.Count() == 0)
            {
                return 0;
            }
            return _context.WePayOrders.Max(x => x.PayTime);
        }

        [HttpGet("{id:long}")]
        public async Task<ResultModel> GetOrderAsync(long id)
        {
            WePayOrder order = await _context.WePayOrders.FirstOrDefaultAsync(x => x.Id == id);
            if (order == null)
            {
                return this.ResultFail("没有找到指定订单");
            }
            return this.ResultSuccess(order);
        }

        [HttpPost]
        public async Task<ResultModel> CreateOrderAsync(WePayOrderDto dto)
        {
            if (dto.OrderAmount < 0.01m)
            {
                return this.ResultFail("参数错误，金额不能小于 0.01 元");
            }

            if (string.IsNullOrWhiteSpace(dto.OrderId))
            {
                return this.ResultFail("参数错误，订单号不能为空");
            }

            if (await _context.WePayOrders.AnyAsync(x => x.OrderId == dto.OrderId))
            {
                return this.ResultFail("订单号已经存在");
            }

            WePayOrder order = new WePayOrder
            {
                OrderId = dto.OrderId,
                OrderAmount = dto.OrderAmount
            };

            _context.WePayOrders.Add(order);
            await _context.SaveChangesAsync();

            Orders.Add(order);

            for (int i = 0; i < 20; i++)
            {
                await Task.Delay(300);
                if (!string.IsNullOrWhiteSpace(order.OrderCode))
                {
                    await _context.SaveChangesAsync();
                    return this.ResultSuccess(order);
                }
            }
            return this.ResultFail("订单生成失败");
        }
    }
}
