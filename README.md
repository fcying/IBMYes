fork [https://github.com/CCChieh/IBMYes](https://github.com/CCChieh/IBMYes)  


# fork修改内容:
* `Secrets` 加入 `V2_ID`, `V2_PATH`, `ALTER_ID`,  
  对应`vmess id`, `ws path`, `alterId`
* 使用actions, 每周自动更新`v2ray`, 部署到 `IBM Cloud Foundray`.


# 配置流程

### 配置IBM Cloud Fonudray
* 注册并登录[https://cloud.ibm.com/](https://cloud.ibm.com/)
* 点击右侧 创建资源
* 点击`Cloud Foundray`
* 创建公共应用程序
* 填写相关信息: 区域达拉斯(免费). 内存最高256M. 应用名称. 配置资源选Python
* 应用程序域名 就是 应用名称+域, 比如: `ibmyes.us-south.cf.appdomain.cloud`
* 点击右侧 创建

### 配置 Cloudflare 高速节点中转
这部分不配置也可以直接连 应用程序域名 使用, 就是有点慢.
* 注册并登录[https://www.cloudflare.com/](https://www.cloudflare.com/)
* 点击 Workers
* 点击 创建Worker
* 在脚本位置加入下面这段, `url.hostname`修改为对应的 应用程序域名.
```
addEventListener(
  "fetch",event => {
    let url=new URL(event.request.url);
    url.hostname="ibmyes.us-south.cf.appdomain.cloud";
    let request=new Request(url,event.request);
    event.respondWith(
      fetch(request)
    )
  }
)
```
* 点击保存并部署, 这里会给一个网址(比如`cloudflare_workers.dev`), 这个就是 v2ray 客户端要连的地址.

### 利用Github Actions 自动部署 IBM Cloud Fonudray
* 返回 github, 到本项目 [https://github.com/fcying/IBMYes](https://github.com/fcying/IBMYes)
* 点击右上角 `Use this template`, 生成一个自己的仓库(设为`public`,如果要用`private`,需要修改`deploy.sh`,提供一个可以下载的`config.json`连接)
* 点击自己仓库的 Settings.
* 点击 `Secrets` 建立以下几个`secret`, 不修改默认值的可以不建:  
    |  |  |
    | ---- | ---- |
    | IBM_ACCOUNT  | IBM Cloud的登录邮箱和密码, 一行邮箱, 一行密码.   |
    | IBM_APP_NAME | IBM应用的名称.|
    | IBM_MEMORY   | IBM应用内存大小, 默认值`128M`.|
    | V2_ID        | vmess id, 默认值`d007eab8-ac2a-4a7f-287a-f0d50ef08680`.|
    | V2_PATH      | ws path, 默认值`path`.|
    | ALTER_ID     | alterId, 默认值`1`.|
    | VLESS_EN     | 是否使用`vless`, 默认值`false`.|
* 点击项目 `Actions`, 点击`IBM Cloud Deploy`, 点击`Run workflow`, 后续每周会自动部署一次(IBM 10天不用会停).
* 如果需要其他配置, 可以编辑自己仓库的`config/config.json`文件.

### 客户端设置
#### Clash
下面为对应的`vmess`部分设置.修改其中的`server`,`uuid`,`alterId`,`path`就好了.
```
  - name: "IBM"
    type: vmess
    server: cloudflare_workers.dev
    port: 443
    uuid: V2_ID
    alterId: ALTER_ID
    cipher: none
    udp: true
    tls: true
    network: ws
    ws-path: /V2_PATH
```

#### v2rayng
```
    address: cloudflare_workers.dev
    port: 443
    id: V2_ID
    alterId: ALTER_ID
    security: none
    network: ws
    path: /V2_PATH
    底层传输安全: tls
```

`server` `address` 可以使用 `cloudflare.com`或者别的`CF`的比较快的IP,对应的加一个伪装设置就行.
```
    clash:
    server: cloudflare.com
    ws-headers:
      Host: cloudflare_workers.dev

    v2rayng:
    address: cloudflare.com
    伪装域名: cloudflare_workers.dev

```
