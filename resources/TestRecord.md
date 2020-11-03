1. Node1(manager：0xA28442dd896426aCB5D98D63C31a2fB6d5D891c0)
   - 部署SC，获取SC地址：0x24a9Da96D0F6cabCCa5aC663C856416c6a1b4BFb
   - 部署OC，获取OC地址：0x40a705E1327A7b2B6cE934950E0FaB7a281f94AD
   
2. Node2(User：0x50996cd854049c9AccDc80c68bF2D5C7B6A434Dc)
   
   - 部署PC，获取PC地址：0x482dC5a56eC5bC96DBb7E7014d4532C863D123B1
   
3. Node1 创建三个账户
   - 制造商M：0x528de916088e86A912881Bfc1c85661d90a4Dd6c
   - Subject1：0xb5d3ceBA61815Cc01add2D8619c468798f3F261f
   - Subject2：0x77517D1C3096A1b9EdD0952F06f502AA9e6C5cb4
   
4. Node1(manager)
   
   - 调用SC，添加 M 到合法制造商列表
   
5. Node1(M：0xAEEE47302F21b218e1bEb20289166C2a8238A1Ed)
   - 调用SC，注册 Subject1，传入MA为 `[type:remotecontrol][mac:00efefefefef]`
   - 调用SC，注册 Subject2，传入MA为 `[type:remotecontrol][mac:00da7eef12ef]`
   
6. Node2 创建一个账户
   
   - Object1：0xBE9f67ECc3C43062f60C6Ba055340FD3F2b8400a
   
7. Node2(Object1)
   - 调用OC，设置OA，传入参数 `[type:TV][location:living]`
   - 调用SC，设置SOA for Subject1，传入 `[group:owner][role:parent]`
   - 调用SC，设置SOA for Subject2，传入` [group:owner][role:chlidren]`
   
8. Node2(User)
   - 调用 PC，添加 Policy
     - resource：switch
     - action：on
     - duty：record
     - algorithm：denyoverrides
   - 调用 PC，添加 Rule1
     - sa：`[type:remotecontrol][mac:00efefefefef][group:owner][role:parent]`
     - oa：`[type:TV][location:living]`
     - ea：`[time:*-*]`
     - result：allow
   - 调用 PC，添加 Rule2
     - sa：`[type:remotecontrol][mac:00da7eef12ef][group:owner][role:chlidren]`
     - oa：`[type:TV][location:living]`
     - ea：`[time:21:00-23:00]`
     - result：deny
   
9. Node1(manager)

   - 部署ACC，传入SC和OC地址，获取ACC地址：0x9C1e55e70d152a75752716A7784f810fDA37E196

   - 调用 ACC，设置EA，`[time:*-*]`

10. Node2(Object1)

    - 调用ACC，绑定 PC 与 Object1

11. Node1(Subject1)

    - 调用ACC，发起访问控制，结果应为 allow

12. Node1(manager)

    - 调用ACC，设置EA，`[time:21:00-23:00]`

13. Node1(Subject2)

    - 调用ACC，发起访问控制，结果应为 deny

