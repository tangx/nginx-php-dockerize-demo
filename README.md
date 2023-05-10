# nginx php demo

## 依赖工具介绍

1. `composer/composer`: php 的一个包依赖管理工具
2. `tangx/envsubst2`: 配置模版渲染工具
3. `docker-php-ext-install`: php 镜像依赖安装方式， hub.docker.com 中有介绍。


## 执行过程介绍

启动时执行 `docker-entrypoint.sh` 启动服务

1. 使用 `tangx/envsubst2` 渲染 nginx 配置
2. nginx **后台** 启动。 由于 nginx 功能为代理 php-fpm， 本身没有复杂业务逻辑。 宕掉的概率不高， 所以没有单独启动， **这里是一个风险点**， 但可以通过 healthy-checking 探测到。

3. `php-fpm` 前台启动。  保持容器运行。 `php-fpm` 时主要业务逻辑， 所以保持前台运行。 进程死掉后可以自动重启。