using System.Diagnostics;
using System.Threading;
using System.Threading.Tasks;

namespace WePayServer.Common
{
    public abstract class BackgroundTask
    {
        private bool _runTaskFlag;
        private readonly object _lock = new object();

        protected abstract Task ExecuteAsync(CancellationToken stoppingToken);

        public void RequestExecute()
        {
            // 不要锁住
            if (_runTaskFlag)
            {
                Debug.WriteLine("BackgroundTask now runing!!!");
                return;
            }


            lock (_lock)
            {
                Task.Run(async () =>
                {
                    _runTaskFlag = true;

                    await ExecuteAsync(default);

                    _runTaskFlag = false;
                });
            }
        }
    }
}
