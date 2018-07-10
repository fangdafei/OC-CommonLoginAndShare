# OC-CommonLoginAndShare
常用的第三方（QQ,微信，微博）登陆和分享： 1，你需要添加各SDK依赖库（点击Project navigator 点击TARGETS —> General —> Linked Frameworks and Libraries 点击加号添加 ） 2，你需要配置你的工程（选中“TARGETS”一栏，在“info”标签栏的“URL type”添加一条新的“URL scheme”，新的scheme = tencent + appid（例如你的appid是123456 则填入tencent123456， identifier 填写：tencentopenapi）；“URL scheme”中填写的信息反馈在openURL和handleOpenURL方法的url中，url会存在“URL scheme”字段。
