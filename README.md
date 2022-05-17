## v2ray-heroku
[![](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy?template=https://github.com/tom-temp/web-get-a.git)

### heroku上部署v2ray
- [x] 支持VMess和VLESS两种协议
- [x] 支持自定义websocket路径
- [x] 伪装首页（alist）

## 使用免费 MySQL 远程数据库（推荐）

由于 Herok 免费账户无法永久保存应用数据，在没有使用正确的方法防止应用休眠情况下，Alist 会被重置。使用远程 MySQL 则可以解决这个问题。

注册免费 MySQL 远程数据库：https://www.db4free.net/

完成注册后，你的邮箱会收到MySQL 连接地址、端口、数据库名称、用户信息。

> 说明来自 https://github.com/sbwml/alist-heroku 项目

### 环境变量说明

|  名称 | 值  | 说明  |
| ------------ | ------------ | ------------ |
|  PROTOCOL |  vmess<br>vless（可选） |  协议：nginx+vmess+ws+tls或是nginx+vless+ws+tls |
|  UUID |  [uuid在线生成器](https://www.uuidgenerator.net "uuid在线生成器") | 用户主ID  |
|  WS_PATH | 默认为`/ray` |  路径，请勿使用`/admin`，`/`，等已经被占用的请求路径 |




### 进阶
heorku可以绑卡（应用一直在线，不扣费），绑定域名，套cf，[uptimerobot](https://uptimerobot.com/) 定时访问防止休眠（只监控CF Workers反代地址好了，不然几个账户一起监控没几天就把时间耗完了）

### CloudFlare Workers反代代码（可分别用两个账号的应用程序名（`PROTOCOL`、`UUID`、`WS_PATH`保持一致），单双号天分别执行，那一个月就有550+550小时）
<details>
<summary>CloudFlare Workers单账户反代代码</summary>

```js
addEventListener(
    "fetch",event => {
        let url=new URL(event.request.url);
        url.hostname="appname.herokuapp.com";
        let request=new Request(url,event.request);
        event. respondWith(
            fetch(request)
        )
    }
)
```
</details>

<details>
<summary>CloudFlare Workers单双日轮换反代代码</summary>

```js
const SingleDay = 'app0.herokuapp.com'
const DoubleDay = 'app1.herokuapp.com'
addEventListener(
    "fetch",event => {

        let nd = new Date();
        if (nd.getDate()%2) {
            host = SingleDay
        } else {
            host = DoubleDay
        }

        let url=new URL(event.request.url);
        url.hostname=host;
        let request=new Request(url,event.request);
        event. respondWith(
            fetch(request)
        )
    }
)
```
</details>

<details>
<summary>CloudFlare Workers每五天轮换一遍式反代代码</summary>

```js
const Day0 = 'app0.herokuapp.com'
const Day1 = 'app1.herokuapp.com'
const Day2 = 'app2.herokuapp.com'
const Day3 = 'app3.herokuapp.com'
const Day4 = 'app4.herokuapp.com'
addEventListener(
    "fetch",event => {

        let nd = new Date();
        let day = nd.getDate() % 5;
        if (day === 0) {
            host = Day0
        } else if (day === 1) {
            host = Day1
        } else if (day === 2) {
            host = Day2
        } else if (day === 3){
            host = Day3
        } else if (day === 4){
            host = Day4
        } else {
            host = Day1
        }

        let url=new URL(event.request.url);
        url.hostname=host;
        let request=new Request(url,event.request);
        event. respondWith(
            fetch(request)
        )
    }
)
```
</details>

<details>
<summary>CloudFlare Workers一周轮换反代代码</summary>

```js
const Day0 = 'app0.herokuapp.com'
const Day1 = 'app1.herokuapp.com'
const Day2 = 'app2.herokuapp.com'
const Day3 = 'app3.herokuapp.com'
const Day4 = 'app4.herokuapp.com'
const Day5 = 'app5.herokuapp.com'
const Day6 = 'app6.herokuapp.com'
addEventListener(
    "fetch",event => {

        let nd = new Date();
        let day = nd.getDay();
        if (day === 0) {
            host = Day0
        } else if (day === 1) {
            host = Day1
        } else if (day === 2) {
            host = Day2
        } else if (day === 3){
            host = Day3
        } else if (day === 4) {
            host = Day4
        } else if (day === 5) {
            host = Day5
        } else if (day === 6) {
            host = Day6
        } else {
            host = Day1
        }

        let url=new URL(event.request.url);
        url.hostname=host;
        let request=new Request(url,event.request);
        event. respondWith(
            fetch(request)
        )
    }
)
```
</details>

### 客户端配置

```
  - name: "yourName"
    type: vmess
    server: yourName.workers.dev
    port: 443
    uuid: yourUuid
    alterId: 0
    cipher: auto
    udp: true
    tls: true
    #skip-cert-verify: true
    servername: yourName.workers.dev
    network: ws
    ws-path: /ray
```
