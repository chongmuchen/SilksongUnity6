# 三个典型Boss完整状态、动作、碰撞与动画附表

本附表为人读和AI规格共同的精确参考。所有表来自本工程序列化数据。动作按Enter顺序排列；禁用动作保留且标`disabled`；`$变量`在运行时读取，`None`表示未选择变量。原始字段、变量初始值与组件全文见bosses-data.json。

## Mossbone Mother

### Mossbone Mother / Stun Control [fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:467846>)

变量初值：`{"floatVariables":{"Combo Time":1,"Daze X Scale":0,"Daze Y Scale":0,"Hits Total":0,"Combo Counter":0,"Stun Damage":0,"Epsilon":0.01},"intVariables":{"Stun Combo":8,"Stun Hit Max":10},"boolVariables":{"Daze Effect Active":0,"Abyss Attacking":0},"gameObjectVariables":{"DazedEffect":{"fileID":0},"DazedEffect Marker":{"fileID":0},"Self":{"fileID":0}}}`

全局迁移：`[{"fsmEvent":{"name":"STUN CONTROL FORCE STUN","isSystemEvent":0,"isGlobal":0},"toState":"Stun","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0},{"fsmEvent":{"name":"STUN CONTROL STOP","isSystemEvent":0,"isGlobal":0},"toState":"Stop Daze Effect 2","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0},{"fsmEvent":{"name":"STUN CONTROL RESET","isSystemEvent":0,"isGlobal":0},"toState":"Stop Daze Effect 3","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0}]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:467863>)

出口：FINISHED → Idle。isSequence=0。

1. `GetOwner(storeGameObject="$Self")`

2. `FindChild(gameObject="Self", childName="DazedEffect Marker", storeResult="$DazedEffect Marker")`



#### Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:467958>)

出口：STUN DAMAGE → Max Check。isSequence=0。

1. `SetFloatValue(floatVariable="$Stun Damage", floatValue=0.0, everyFrame=false)`



#### In Combo · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:468024>)

出口：TIME OUT → Reset Counter；STUN DAMAGE → Continue Combo；STUN → Stun。isSequence=0。

1. `FloatAdd(floatVariable="$Combo Counter", add="$Stun Damage", everyFrame=false, perSecond=false)`

2. `FloatAdd(floatVariable="$Hits Total", add="$Stun Damage", everyFrame=false, perSecond=false)`

3. `SetFloatValue(floatVariable="$Stun Damage", floatValue=0.0, everyFrame=false)`

4. **disabled** `FloatCompare(float1="$Combo Counter", float2="$Stun Combo", tolerance="$Epsilon", equal="STUN", lessThan=null, greaterThan="STUN", everyFrame=false)`

5. `Wait(time="$Combo Time", finishEvent="TIME OUT", realTime=false)`



#### Reset Counter · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:468134>)

出口：FINISHED → Stop Daze Effect。isSequence=0。

1. `SetFloatValue(floatVariable="$Combo Counter", floatValue=0.0, everyFrame=false)`



#### Continue Combo · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:468200>)

出口：FINISHED → In Combo；STUN → Stun。isSequence=0。

1. `BoolTest(boolVariable="$Abyss Attacking", isTrue="FINISHED", isFalse=null, everyFrame=false)`

2. `FloatCompare(float1="$Hits Total", float2="$Stun Hit Max", tolerance="$Epsilon", equal="STUN", lessThan=null, greaterThan="STUN", everyFrame=false)`



#### Stun · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:468285>)

出口：FINISHED → Dazed Effect。isSequence=0。

1. `SpawnObjectFromGlobalPool(gameObject="GUID:5283cc506c688be448065d0227ce1390#1709254077376921", spawnPoint="$Self", position="None", rotation="None", storeObject="None")`

2. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="STUN", delay=0.0, everyFrame=false)`

3. `SetFloatValue(floatVariable="$Combo Counter", floatValue=0.0, everyFrame=false)`

4. `SetFloatValue(floatVariable="$Hits Total", floatValue=0.0, everyFrame=false)`

5. `SendMessage(gameObject="Self", delivery=0, options=1, functionCall={"FunctionName":"ResetSingCooldown","parameterType":"None","BoolParameter":0,"FloatParameter":0,"IntParameter":0,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`



#### Max Check · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:468562>)

出口：FINISHED → In Combo；STUN → Stun。isSequence=0。

1. `BoolTest(boolVariable="$Abyss Attacking", isTrue="FINISHED", isFalse=null, everyFrame=false)`

2. `FloatCompare(float1="$Hits Total", float2="$Stun Hit Max", tolerance="$Epsilon", equal="STUN", lessThan="FINISHED", greaterThan="STUN", everyFrame=false)`



#### Stop · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:468647>)

出口：STUN CONTROL START → Reset Counter；STUN DAMAGE → Unstun Increment。isSequence=0。



#### Unstun Increment · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:468717>)

出口：FINISHED → Stop。isSequence=0。

1. `FloatAdd(floatVariable="$Hits Total", add="$Stun Damage", everyFrame=false, perSecond=false)`

2. `SetFloatValue(floatVariable="$Stun Damage", floatValue=0.0, everyFrame=false)`



#### Reset · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:468789>)

出口：STUN CONTROL START → Reset Counter。isSequence=0。

1. `SetFloatValue(floatVariable="$Hits Total", floatValue=0.0, everyFrame=false)`



#### Dazed Effect · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:468855>)

出口：FINISHED → Stunned。isSequence=0。

1. `GameObjectIsNull(gameObject="$DazedEffect Marker", isNull="FINISHED", isNotNull=null, storeResult="None", everyFrame=false)`

2. `GetScale(gameObject="Owner($DazedEffect Marker)", vector="None", xScale="$Daze X Scale", yScale="$Daze Y Scale", zScale="None", space=0, everyFrame=false)`

3. `SpawnObjectFromGlobalPool(gameObject="GUID:da2b82da172005b4cb576be2afe73009#1709254077376921", spawnPoint="$DazedEffect Marker", position="None", rotation="None", storeObject="$DazedEffect")`

4. `SetScale(gameObject="Owner($DazedEffect)", vector="None", x="$Daze X Scale", y="$Daze Y Scale", z="None", everyFrame=false, lateUpdate=false)`

5. **disabled** `Tk2dPlayAnimation(gameObject="Owner($DazedEffect)", animLibName=null, clipName="Dazed")`

6. `SetParent(gameObject="Owner($DazedEffect)", parent="$Self", resetLocalPosition=false, resetLocalRotation=false)`



#### Stun End · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:469033>)

出口：FINISHED → Stop Daze Effect。isSequence=0。

1. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:b1c29b3804a260f4d83275f93b80ade4#8300000", pitchMin=1.0, pitchMax=1.0, volume=1.0, delay=0.0, storePlayer="fileID:0")`



#### Stunned · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:469129>)

出口：STUN CONTROL START → Stun End；TOOK HEAVY DAMAGE → Quick End。isSequence=0。



#### Quick End · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:469199>)

出口：FINISHED → Stunned；STUN CONTROL START → Stun End。isSequence=0。

1. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="END", delay=0.0, everyFrame=false)`



#### Stop Daze Effect · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:469313>)

出口：FINISHED → Idle。isSequence=0。

1. `GameObjectIsNull(gameObject="$DazedEffect", isNull="FINISHED", isNotNull=null, storeResult="None", everyFrame=false)`

2. **disabled** `Tk2dPlayAnimation(gameObject="Owner($DazedEffect)", animLibName=null, clipName="Dazed End")`

3. **disabled** `Tk2dPlayFrame(gameObject="Self", frame=0)`

4. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($DazedEffect)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="STUN EFFECT END", delay=0.0, everyFrame=false)`

5. `AudioStop(gameObject="Owner($DazedEffect)", fadeTime=0.0)`

6. `SetGameObject(variable="$DazedEffect", gameObject="fileID:0", everyFrame=false)`



#### Stop Daze Effect 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:469497>)

出口：FINISHED → Stop。isSequence=0。

1. `GameObjectIsNull(gameObject="$DazedEffect", isNull="FINISHED", isNotNull=null, storeResult="None", everyFrame=false)`

2. **disabled** `Tk2dPlayAnimation(gameObject="Owner($DazedEffect)", animLibName=null, clipName="Dazed End")`

3. **disabled** `Tk2dPlayFrame(gameObject="Self", frame=0)`

4. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($DazedEffect)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="STUN EFFECT END", delay=0.0, everyFrame=false)`

5. `AudioStop(gameObject="Owner($DazedEffect)", fadeTime=0.0)`

6. `SetGameObject(variable="$DazedEffect", gameObject="fileID:0", everyFrame=false)`



#### Stop Daze Effect 3 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:469681>)

出口：FINISHED → Reset。isSequence=0。

1. `GameObjectIsNull(gameObject="$DazedEffect", isNull="FINISHED", isNotNull=null, storeResult="None", everyFrame=false)`

2. **disabled** `Tk2dPlayAnimation(gameObject="Owner($DazedEffect)", animLibName=null, clipName="Dazed End")`

3. **disabled** `Tk2dPlayFrame(gameObject="Self", frame=0)`

4. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($DazedEffect)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="STUN EFFECT END", delay=0.0, everyFrame=false)`

5. `AudioStop(gameObject="Owner($DazedEffect)", fadeTime=0.0)`

6. `SetGameObject(variable="$DazedEffect", gameObject="fileID:0", everyFrame=false)`



### Mossbone Mother / Control [fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:521371>)

变量初值：`{"floatVariables":{"Accel":0,"Antic Speed":0,"Centre X":57.37,"Hero X":0,"Idle Time":2,"Left X":46.43,"Max Height":23.8,"Recover Time":0.75,"Right X":67.92,"Self X":0,"Self Y":0,"Speed Crt":0,"Stun Timer":0,"Swoop Height":18.19,"Swoop Target":0,"Swoop X Speed":18,"Timer":0,"X Pos":0,"X Scale":0,"Offset":0,"Recoil Dir":0,"Recoil Speed":0,"Z Pos":0,"Velocity Y":0},"intVariables":{"Ct Crawler":0,"Ct Rock":1,"Ct Slam":0,"Ct Swoop":2,"HP":0,"HP Half":0,"HP P2":0,"HP Call Buddy":0},"boolVariables":{"Called Buddy":0,"Done First Spawn":0,"Double Fight":0,"Double Fight Buddy":0,"Hero Left":0,"Hero Right":0,"Ready To Call":0,"Spawned":0,"Under Hero":0,"z Always Stay Left":0,"z Always Stay Right":0},"vector2Variables":{"Extract pos":{"x":0,"y":0},"Entry Pos Double":{"x":0,"y":0},"Ground Ray Point":{"x":0,"y":0},"Slam Antic Vector":{"x":0,"y":0}},"vector3Variables":{"Swoop Vector":{"x":0,"y":0,"z":0}},"gameObjectVariables":{"Appear Rubble":{"fileID":480},"Battle Motes":{"fileID":0},"Battle Scene":{"fileID":460},"Cocoon":{"fileID":0},"Cocoon Break":{"fileID":0},"Cocoon Mound":{"fileID":1792},"DazedEffect":{"fileID":0},"DazedEffect Marker":{"fileID":0},"Pt Drip":{"fileID":1792},"Pt Dust":{"fileID":0},"Pt Idle":{"fileID":1073},"Pt Roar":{"fileID":0},"Pt Slam":{"fileID":1073},"Pt SwoopDust":{"fileID":0},"Pt SwoopRock":{"fileID":259},"Self":{"fileID":1186},"Shake Drip":{"fileID":259},"Shake Rubble":{"fileID":1186},"Sound Player":{"fileID":1485},"Spawn Crawler":{"fileID":1485},"Spawn Crawler 2":{"fileID":1489},"Stals":{"fileID":393},"Strike":{"fileID":0},"Terrain Block":{"fileID":981},"Trap Cocoons":{"fileID":981},"Hero":{"fileID":0},"Extract Point":{"fileID":0},"Pt BuddyEntryAntic":{"fileID":1631},"Parent":{"fileID":0},"Audio Loop Voice":{"fileID":1869}}}`

全局迁移：`[{"fsmEvent":{"name":"EXTRACT","isSystemEvent":0,"isGlobal":0},"toState":"Get Dir","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0},{"fsmEvent":{"name":"STUN","isSystemEvent":0,"isGlobal":0},"toState":"Stun Start","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0},{"fsmEvent":{"name":"ZERO HP","isSystemEvent":0,"isGlobal":0},"toState":"End","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0}]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:521388>)

出口：FINISHED → Dormant。isSequence=1。

1. `NextFrameEvent(sendEvent=null)`

2. `GetOwner(storeGameObject="$Self")`

3. `GetHero(storeResult="$Hero")`

4. `GetHP(target="Self", storeValue="$HP")`

5. `GetParent(gameObject="Self", storeResult="$Parent")`

6. `MultiplyIntByFloat(integer="$HP", multiplyFloat=0.95, storeResult="$HP P2", everyFrame=false, forceRoundUp=false)`

7. `MultiplyIntByFloat(integer="$HP", multiplyFloat=0.85, storeResult="$HP Call Buddy", everyFrame=false, forceRoundUp=false)`

8. `MultiplyIntByFloat(integer="$HP", multiplyFloat=0.7, storeResult="$HP Half", everyFrame=false, forceRoundUp=false)`

9. `FindChild(gameObject="Self", childName="Cocoon", storeResult="$Cocoon")`

10. `FindChild(gameObject="Self", childName="Cocoon Break", storeResult="$Cocoon Break")`

11. `FindChild(gameObject="Self", childName="Strike", storeResult="$Strike")`

12. `FindChild(gameObject="Self", childName="Pt Drip", storeResult="$Pt Drip")`

13. `FindChild(gameObject="Self", childName="Pt Dust", storeResult="$Pt Dust")`

14. `FindChild(gameObject="Self", childName="Pt SwoopDust", storeResult="$Pt SwoopDust")`

15. `FindChild(gameObject="Self", childName="Pt SwoopRock", storeResult="$Pt SwoopRock")`

16. `FindChild(gameObject="Self", childName="Terrain Block", storeResult="$Terrain Block")`

17. `FindChild(gameObject="Self", childName="Pt Idle", storeResult="$Pt Idle")`

18. `FindChild(gameObject="Self", childName="Pt Roar", storeResult="$Pt Roar")`

19. **disabled** `FindChild(gameObject="Self", childName="DazedEffect Marker", storeResult="$DazedEffect Marker")`



#### Dormant · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:521857>)

出口：BLOCKED HIT → Check Hero in Room；RETURN → Return Ready；COCOON KILL → Check Hero in Room；DOUBLE → Return Ready 2；BUDDY → Buddy；WAKE → Start Battle；NOISE → Check Hero in Room。isSequence=0。

1. `SetCollider(gameObject="Self", active=0, resetOnExit=false)`

2. `SetAudioSource(gameObject="Self", active=0)`

3. `BoolTest(boolVariable="$Double Fight Buddy", isTrue="BUDDY", isFalse=null, everyFrame=false)`

4. `BoolTest(boolVariable="$Double Fight", isTrue="DOUBLE", isFalse=null, everyFrame=false)`

5. `PlayerDataBoolTest(boolName="encounteredMossMother", isTrue="RETURN", isFalse=null)`

6. `CheckAlertRangeByName(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, alertRangeName="Wake Range", storeResult=0, sendEvent="WAKE", outOfRangeEvent=null, everyFrame=true)`

7. `CheckHeroPerformanceRegion(Target="Self", MinReactDelay=0.3, MaxReactDelay=0.3, None=null, ActiveInner="NOISE", ActiveOuter="NOISE", IgnoreNeedolinRange=0, useActiveBool=false, ActiveBool="None", StoreState="None", EveryFrame=true)`



#### Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:522164>)

出口：NEEDOLIN → Sing Antic；TOOK DAMAGE → Dmg Response；WAIT → Check First Idle；DOUBLE → Idle D。isSequence=0。

1. `BoolTest(boolVariable="$Double Fight", isTrue="DOUBLE", isFalse=null, everyFrame=false)`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Fly")`

3. `FaceObject(objectA="$Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=true, newAnimationClip="TurnToFly", resetFrame=true, everyFrame=true)`

4. `GetPosition(gameObject="Owner($Hero)", vector="None", x="$Hero X", y="None", z="None", space=0, everyFrame=true)`

5. `FloatTestToBool(float1="$Hero X", float2="$Centre X", tolerance=0, equalBool="None", lessThanBool="$Hero Left", greaterThanBool="$Hero Right", everyFrame=true)`

6. `DistanceFlyV2(gameObject="Self", target="$Hero", distance=12, speedMax=6, acceleration=0.375, targetsHeight=true, height=6, maxHeight="$Max Height", stayLeft=0, stayRight=0)`

7. `CheckHeroPerformanceRegionV2(Target="Self", Radius=10, MinReactDelay=0.3, MaxReactDelay=0.4, None=null, ActiveInner="NEEDOLIN", ActiveOuter=null, IgnoreNeedolinRange=0, UseActiveBool=0, ActiveBool="None", StoreState="None", EveryFrame=true)`

8. `FloatAdd(floatVariable="$Timer", add=1, everyFrame=true, perSecond=true)`

9. `FloatCompare(float1="$Timer", float2="$Idle Time", tolerance=0, equal="WAIT", lessThan=null, greaterThan="WAIT", everyFrame=true)`



#### Move Choice · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:522594>)

出口：SWOOP → Swoop Antic；SLAM → Reduce Idle Time 2；DOUBLE → Move Choice D；NEEDOLIN → Sing Antic。isSequence=0。

1. `SetFloatValue(floatVariable="$Timer", floatValue=0, everyFrame=false)`

2. `CheckHeroPerformanceRegionV2(Target="Self", Radius=10, MinReactDelay=0, MaxReactDelay=0, None=null, ActiveInner="NEEDOLIN", ActiveOuter=null, IgnoreNeedolinRange=0, UseActiveBool=0, ActiveBool="None", StoreState="None", EveryFrame=false)`

3. `BoolTest(boolVariable="$Double Fight", isTrue="DOUBLE", isFalse=null, everyFrame=false)`

4. `GetHP(target="Self", storeValue="$HP")`

5. `IntCompare(integer1="$HP", integer2="$HP P2", equal=null, lessThan=null, greaterThan="SWOOP", everyFrame=false)`

6. `SendRandomEventV2(events=["SLAM","SWOOP"], weights=[1,1], trackingInts=["$Ct Slam","$Ct Swoop"], eventMax=[1,2])`



#### Swoop Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:522878>)

出口：FINISHED → Swoop。isSequence=0。

1. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Antic")`

2. `Wait(time=0.4, finishEvent="FINISHED", realTime=false)`

3. `DecelerateV2(gameObject="Self", deceleration=0.75, brakeOnExit=false)`

4. `ObjectJitter(gameObject="Self", x=0.1, y=0.1, z="None", allowMovement=0, limitFps=0)`

5. `FadeAudio(gameObject="Self", startVolume=1, endVolume=0, time=0.3)`

6. `AudioPlayRandomVoiceFromTable(gameObject="Owner($Audio Loop Voice)", audioClipTable="GUID:950f2aff4b3e46440bc307b115843fae#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`



#### Swoop · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:523095>)

出口：FINISHED → Swoop Extend。isSequence=0。

1. `SetRecoilBlocked(Target="Self", IsUpBlocked=1, IsDownBlocked=1, IsLeftBlocked=0, IsRightBlocked=0)`

2. `RayCast2dV2(fromGameObject="Self", fromPosition="None", direction={"x":0,"y":-1}, space=1, distance=20, minDepth="None", maxDepth="None", hitEvent=null, noHitEvent=null, storeDidHit="None", storeHitObject="None", storeHitPoint="$Ground Ray Point", storeHitNormal="None", storeHitDistance="None", storeDistance="None", repeatInterval=0, layerMask=[8], invertMask=0, ignoreTriggers=0, debugColor={"r":1,"g":0.92156863,"b":0.015686275,"a":1}, debug=0)`

3. `GetVector2XY(vector2Variable="$Ground Ray Point", storeX="None", storeY="$Swoop Height", everyFrame=false)`

4. `FloatAdd(floatVariable="$Swoop Height", add=2.2, everyFrame=false, perSecond=false)`

5. `GetScale(gameObject="Self", vector="None", xScale="$X Scale", yScale="None", zScale="None", space=0, everyFrame=false)`

6. `FloatOperator(float1="$Swoop X Speed", float2="$X Scale", operation=2, storeResult="$Speed Crt", everyFrame=false)`

7. `FloatOperator(float1="$Speed Crt", float2=-1.3, operation=2, storeResult="$Antic Speed", everyFrame=false)`

8. `SetVelocity2d(gameObject="Self", vector="None", x="$Antic Speed", y="None", everyFrame=false)`

9. `FloatOperator(float1="$Speed Crt", float2=0.1, operation=2, storeResult="$Accel", everyFrame=false)`

10. `KeepFloatPositive(floatVariable="$Accel", everyFrame=false)`

11. `AccelerateToX(gameObject="Self", accelerationFactor="$Accel", targetSpeed="$Speed Crt")`

12. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Charge")`

13. `GetPosition(gameObject="Self", vector="None", x="None", y="$Self Y", z="None", space=0, everyFrame=false)`

14. `SetFloatValue(floatVariable="$Swoop Target", floatValue="$Swoop Height", everyFrame=false)`

15. `FloatSubtract(floatVariable="$Swoop Target", subtract="$Self Y", everyFrame=false, perSecond=false)`

16. `SetVector3XYZ(vector3Variable="$Swoop Vector", vector3Value="None", x=0, y="$Swoop Target", z=0, everyFrame=false)`

17. `iTweenMoveBy(gameObject="Self", id="None", vector="$Swoop Vector", time=0.5, delay=0, speed="None", easeType=14, loopType=0, space=0, orientToPath=0, lookAtObject="None", lookAtVector="None", lookTime=0, axis=0, startEvent=null, finishEvent=null, realTime=0, stopOnExit=1, loopDontFinish=1)`

18. `Wait(time=0.9, finishEvent="FINISHED", realTime=false)`

19. `PlayParticleEmitter(gameObject="Owner($Pt SwoopDust)", emit=0, resetIfPlaying=false)`

20. `PlayParticleEmitter(gameObject="Owner($Pt SwoopRock)", emit=0, resetIfPlaying=false)`

21. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:3e8ce2d10aff3aa4b85ff863101cf523#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Swoop Return · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:523909>)

出口：FINISHED → Swoop Recover。isSequence=0。

1. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Charge Recover")`

2. `DecelerateXY(gameObject="Self", decelerationX=0.95, decelerationY="None", brakeOnExit=false)`

3. `Wait(time=0.5, finishEvent="FINISHED", realTime=false)`

4. `FadeAudio(gameObject="Self", startVolume=0, endVolume=1, time=0.4)`

5. `SetRecoilBlocked(Target="Self", IsUpBlocked=0, IsDownBlocked=0, IsLeftBlocked=0, IsRightBlocked=0)`



#### Swoop Recover · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:524104>)

出口：FINISHED → Idle；TOOK DAMAGE → Idle；SPAWNED → Crawler Idle。isSequence=0。

1. `BoolTest(boolVariable="$Spawned", isTrue="SPAWNED", isFalse=null, everyFrame=false)`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Fly")`

3. `FaceObject(objectA="$Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=true, newAnimationClip="TurnToFly", resetFrame=true, everyFrame=true)`

4. `Wait(time=0.65, finishEvent="FINISHED", realTime=false)`

5. `AccelerateToY(gameObject="Self", accelerationFactor=0.1, targetSpeed=6)`

6. `DecelerateXY(gameObject="Self", decelerationX=0.95, decelerationY="None", brakeOnExit=false)`



#### Slam Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:524318>)

出口：FINISHED → Set Antic Dir。isSequence=0。

1. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Antic")`

2. `Wait(time=0.4, finishEvent="FINISHED", realTime=false)`

3. `DecelerateV2(gameObject="Self", deceleration=0.9, brakeOnExit=false)`

4. `FadeAudio(gameObject="Self", startVolume=1, endVolume=0, time=0.3)`

5. `SetFloatValue(floatVariable="$Idle Time", floatValue=2.25, everyFrame=false)`

6. `AudioPlayRandomVoiceFromTable(gameObject="Owner($Audio Loop Voice)", audioClipTable="GUID:950f2aff4b3e46440bc307b115843fae#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`



#### Fly Up · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:524506>)

出口：SLAM → Slam。isSequence=0。

1. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="FlyUp")`

2. `SetVelocity2d(gameObject="Self", vector="None", x="None", y=25, everyFrame=false)`

3. `DecelerateXY(gameObject="Self", decelerationX=0.85, decelerationY="None", brakeOnExit=false)`

4. `CheckCollisionSide(collidingObject="Self", topHit="None", rightHit="None", bottomHit="None", leftHit="None", topHitEvent="SLAM", rightHitEvent="SLAM", bottomHitEvent=null, leftHitEvent="SLAM", otherLayer=false, otherLayerNumber=0, ignoreTriggers=0)`

5. `CheckCollisionSideEnter(topHit="None", rightHit="None", bottomHit="None", leftHit="None", topHitEvent="SLAM", rightHitEvent=null, bottomHitEvent=null, leftHitEvent=null, otherLayer=false, otherLayerNumber=0, ignoreTriggers=0)`

6. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:9d84ff4f1bb528744aa1846d91ad8e30#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

7. `GetVelocity2d(gameObject="Self", vector="None", x="None", y="$Velocity Y", space=0, everyFrame=true)`

8. `FloatCompare(float1="$Velocity Y", float2=0, tolerance=0.1, equal="SLAM", lessThan=null, greaterThan=null, everyFrame=true)`

9. `Wait(time=1, finishEvent="SLAM", realTime=false)`



#### Slam · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:524889>)

出口：FINISHED → Drop Type。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Smash", animationTriggerEvent=null, animationCompleteEvent=null)`

2. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($CameraParent)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="AverageShake", delay=0, everyFrame=false)`

3. `PlayParticleEmitter(gameObject="Owner($Pt Slam)", emit=0, resetIfPlaying=false)`

4. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:a494cbac2a5d26f4885070238d5d72ec#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

5. `SendEvent(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="FINISHED", delay=0, everyFrame=false)`



#### Swoop Extend · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:525145>)

出口：FINISHED → Swoop Return。isSequence=0。

1. `SetBoolValue(boolVariable="$Under Hero", boolValue=1, everyFrame=false)`

2. `GetPosition(gameObject="Self", vector="None", x="$Self X", y="None", z="None", space=0, everyFrame=true)`

3. `GetPosition(gameObject="Owner($Hero)", vector="None", x="$Hero X", y="None", z="None", space=0, everyFrame=true)`

4. `FloatCompare(float1="$Self X", float2="$Left X", tolerance=0, equal="FINISHED", lessThan="FINISHED", greaterThan=null, everyFrame=true)`

5. `FloatCompare(float1="$Self X", float2="$Right X", tolerance=0, equal="FINISHED", lessThan=null, greaterThan="FINISHED", everyFrame=true)`

6. `FloatTestToBool(float1="$Hero X", float2="$Self X", tolerance=2, equalBool="$Under Hero", lessThanBool="None", greaterThanBool="None", everyFrame=true)`

7. `BoolTest(boolVariable="$Under Hero", isTrue=null, isFalse="FINISHED", everyFrame=true)`



#### Slam Antic 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:525424>)

出口：FINISHED → Fly Up。isSequence=0。

1. `Wait(time=0.3, finishEvent="FINISHED", realTime=false)`

2. `DecelerateV2(gameObject="Self", deceleration=0.9, brakeOnExit=false)`

3. `SetVelocity2d(gameObject="Self", vector="$Slam Antic Vector", x="None", y="None", everyFrame=false)`

4. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="RoofAntic")`



#### Drop Type · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:525574>)

出口：CRAWLER → 2nd Crawler；ROCK → Rock；DOUBLE → Drop Type 2。isSequence=0。

1. **disabled** `SendEventByName(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="CRAWLER", delay=0, everyFrame=false)`

2. `BoolTest(boolVariable="$Double Fight", isTrue="DOUBLE", isFalse=null, everyFrame=false)`

3. `GetHP(target="Self", storeValue="$HP")`

4. `IntCompare(integer1="$HP", integer2="$HP Half", equal=null, lessThan=null, greaterThan="ROCK", everyFrame=false)`

5. `SendRandomEventV2(events=["ROCK","CRAWLER"], weights=[1,1], trackingInts=["$Ct Rock","$Ct Crawler"], eventMax=[1,1])`



#### Rock · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:525814>)

出口：FINISHED → Anim End；DOUBLE → Rock - DB。isSequence=0。

1. `BoolTest(boolVariable="$Double Fight", isTrue="DOUBLE", isFalse=null, everyFrame=false)`

2. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Stals)","fsmName":null,"sendToChildren":1,"fsmComponent":"fileID:0"}, sendEvent="FALL", delay=0, everyFrame=false)`



#### Slam Recover · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:525948>)

出口：FINISHED → Idle；TOOK DAMAGE → Idle。isSequence=0。

1. `FaceObject(objectA="$Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=true, newAnimationClip="TurnToFly", resetFrame=true, everyFrame=true)`

2. `Wait(time="$Recover Time", finishEvent="FINISHED", realTime=false)`

3. `DistanceFlyV2(gameObject="Self", target="$Hero", distance=10, speedMax=6, acceleration=0.375, targetsHeight=true, height=7, maxHeight="None", stayLeft=0, stayRight=0)`



#### Slam RePos · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:526131>)

出口：FINISHED → Slam Recover。isSequence=0。

1. `BoolTest(boolVariable="$Double Fight", isTrue="FINISHED", isFalse=null, everyFrame=false)`

2. `SetVelocity2d(gameObject="Self", vector={"x":0,"y":-10}, x="None", y="None", everyFrame=false)`

3. `GetPosition(gameObject="Self", vector="None", x="None", y="$Self Y", z="None", space=1, everyFrame=true)`

4. `FloatCompare(float1="$Self Y", float2=1, tolerance=0, equal=null, lessThan="FINISHED", greaterThan=null, everyFrame=true)`



#### Slam Wait · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:526310>)

出口：FINISHED → Slam RePos。isSequence=0。

1. `Wait(time=0.5, finishEvent="FINISHED", realTime=false)`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Fly")`

3. `FadeAudio(gameObject="Self", startVolume=0, endVolume=1, time=0.4)`



#### Rumble · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:526440>)

出口：FINISHED → Burst Out。isSequence=0。

1. `PlayAudioEvent(audioClip="GUID:0707ef931742c7b46bc910847a37e80e#8300000", pitchMin=1, pitchMax=1, volume=1, audioPlayerPrefab="None", spawnPoint="Self", spawnPosition={"x":0,"y":0,"z":0}, SpawnedPlayerRef="None")`

2. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:9cf29171e309dee4ea00de9b3dbd6c6e#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="$Sound Player")`

3. `ObjectJitter(gameObject="Self", x=0.15, y=0.15, z="None", allowMovement=0, limitFps=0)`

4. `SetFsmBool(gameObject="Owner($CameraParent)", fsmName="CameraShake", variableName="RumblingSmall", setValue=1, everyFrame=false)`

5. `Wait(time=2, finishEvent="FINISHED", realTime=false)`

6. `PlayParticleEmitter(gameObject="Owner($Pt Drip)", emit=0, resetIfPlaying=false)`

7. `PlayParticleEmitterInState(gameObject="Owner($Shake Drip)")`

8. `PlayParticleEmitterInState(gameObject="Owner($Shake Rubble)")`

9. `StartRoarEmitter(spawnPoint="Self", delay=0, stunHero=0, roarBurst=1, isSmall=0, noVisualEffect=0, forceThroughBind=0, stopOnExit=false)`



#### Burst Out · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:526808>)

出口：FINISHED → Roar。isSequence=0。

1. `PlayAudioEvent(audioClip="GUID:19ec61849188a9c46950b87583d24b29#8300000", pitchMin=1, pitchMax=1, volume=1, audioPlayerPrefab="None", spawnPoint="Self", spawnPosition={"x":0,"y":0,"z":0}, SpawnedPlayerRef="None")`

2. `AudioStop(gameObject="Owner($Sound Player)", fadeTime=0)`

3. `ActivateGameObject(gameObject="Owner($Cocoon Break)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

4. `SetInvincible(target="Self", Invincible=0, InvincibleFromDirection=0, resetOnStateExit=false)`

5. `ActivateGameObject(gameObject="Owner($Cocoon Mound)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

6. `ActivateGameObject(gameObject="Owner($Cocoon)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

7. `SetMeshRenderer(gameObject="Self", active=1)`

8. `FaceObject(objectA="$Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false)`

9. `SetFsmBool(gameObject="Owner($CameraParent)", fsmName="CameraShake", variableName="RumblingSmall", setValue=0, everyFrame=false)`

10. `SetVelocity2d(gameObject="Self", vector="None", x="None", y=-30, everyFrame=false)`

11. `Wait(time=1, finishEvent="FINISHED", realTime=false)`

12. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Antic")`

13. `DecelerateXY(gameObject="Self", decelerationX="None", decelerationY=0.85, brakeOnExit=false)`

14. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($CameraParent)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="BigShake", delay=0, everyFrame=false)`

15. `ActivateGameObject(gameObject="Owner($Strike)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

16. `PlayParticleEmitter(gameObject="Owner($Pt Idle)", emit=0, resetIfPlaying=false)`



#### Roar End · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:527332>)

出口：FINISHED → Idle。isSequence=0。

1. `StopRoarEmitter(delay=0)`

2. `SetCollider(gameObject="Self", active=1, resetOnExit=false)`

3. `SetInvincible(target="Self", Invincible=0, InvincibleFromDirection=0, resetOnStateExit=false)`

4. `ApplyMusicCue(musicCue="GUID:2543d8236845aa74ca1b0d53b0d62a4e#11400000", delayTime=0, transitionTime=0)`

5. `TransitionToAudioSnapshot(snapshot="GUID:1e5b83863824c3e46b1a27345f960db5#24500036", transitionTime=0.1)`

6. `SetPlayerDataBool(boolName="encounteredMossMother", value=1)`

7. `ActivateGameObject(gameObject="Owner($Terrain Block)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`



#### Crawler · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:527531>)

出口：FINISHED → Reduce Idle Time。isSequence=0。

1. `SetBoolValue(boolVariable="$Done First Spawn", boolValue=1, everyFrame=false)`

2. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Spawn Crawler)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="SPAWN", delay=0, everyFrame=false)`

3. `SetBoolValue(boolVariable="$Spawned", boolValue=1, everyFrame=false)`



#### Crawler Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:527676>)

出口：KILLED → Slam Recover；TOOK DAMAGE → Swoop Antic；FINISHED → Slam Recover。isSequence=0。

1. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Fly")`

2. `FaceObject(objectA="$Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=true, newAnimationClip="TurnToFly", resetFrame=true, everyFrame=true)`

3. `DistanceFlyV2(gameObject="Self", target="$Hero", distance=10, speedMax=6, acceleration=0.5, targetsHeight=true, height=8, maxHeight="$Max Height", stayLeft=0, stayRight=0)`

4. `BoolTest(boolVariable="$Spawned", isTrue=null, isFalse="KILLED", everyFrame=true)`

5. `Wait(time=1, finishEvent="FINISHED", realTime=false)`



#### Anim End · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:527907>)

出口：FINISHED → Slam Wait。isSequence=0。

1. `Tk2dWatchAnimationEvents(gameObject="Self", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`



#### Anim End 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:527983>)

出口：FINISHED → Crawler Idle；KILLED → Slam Recover。isSequence=0。

1. `Tk2dWatchAnimationEvents(gameObject="Self", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `BoolTest(boolVariable="$Spawned", isTrue=null, isFalse="KILLED", everyFrame=true)`



#### Start Battle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:528082>)

出口：FINISHED → Short Pause。isSequence=0。

1. `CallMethodProper(gameObject="Owner($Battle Scene)", behaviour="BattleScene", methodName="StartBattle", parameters=[], storeResult={"variableName":null,"objectType":"UnityEngine.Object","useVariable":1,"type":-1,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}, EveryFrame=false)`



#### Short Pause · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:528196>)

出口：FINISHED → Rumble。isSequence=0。

1. `Wait(time=0.5, finishEvent="FINISHED", realTime=false)`



#### End · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:528269>)

出口：DOUBLE → Double End。isSequence=0。

1. **disabled** `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Spawn Crawler)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="BOSS KILL", delay=0, everyFrame=false)`

2. `BoolTest(boolVariable="$Double Fight", isTrue="DOUBLE", isFalse=null, everyFrame=false)`

3. `SendEventToRegister(eventName="BOSS KILL")`

4. `TransitionToAudioSnapshot(snapshot="GUID:1e5b83863824c3e46b1a27345f960db5#24500034", transitionTime=1)`

5. `SetPlayerDataBool(boolName="defeatedMossMother", value=1)`

6. `StopParticleEmitter(gameObject="Owner($Battle Motes)")`

7. `Tk2dPlayAnimation(gameObject="Owner($DazedEffect)", animLibName=null, clipName="Dazed End")`

8. `SendEventToRegister(eventName="MOSS SONG END")`



#### Roar · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:528481>)

出口：FINISHED → Reset Bind Prompt?。isSequence=0。

1. `SetAudioSource(gameObject="Self", active=1)`

2. `DisplayBossTitle(areaTitleObject="$AreaTitle", displayRight=0, bossTitle="MOSSBONE_MOTHER")`

3. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:75fcdd74fbd52b243ad4b7657b22eee3#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

4. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:7b31832c38310bd469ae8734210fb9f7#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

5. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:cadfc16ee055c944da51081b220f0a1a#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

6. `SetIsKinematic2d(gameObject="Self", isKinematic=0)`

7. `Wait(time=2, finishEvent="FINISHED", realTime=false)`

8. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Roar")`

9. `SetVelocity2d(gameObject="Self", vector={"x":0,"y":0}, x="None", y="None", everyFrame=false)`

10. `StartRoarEmitter(spawnPoint="Self", delay=0, stunHero=1, roarBurst=0, isSmall=0, noVisualEffect=0, forceThroughBind=0, stopOnExit=false)`

11. `PlayParticleEmitter(gameObject="Owner($Pt Roar)", emit=0, resetIfPlaying=false)`

12. `PlayParticleEmitter(gameObject="Owner($Battle Motes)", emit=0, resetIfPlaying=false)`

13. `SendEventToRegister(eventName="COCOON DESTROY")`



#### Return Ready · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:528949>)

出口：BATTLE START → Return Pause。isSequence=0。

1. `SetPosition(gameObject="Self", vector="None", x="None", y=99, z="None", space=0, everyFrame=false, lateUpdate=false)`

2. `ActivateGameObject(gameObject="Owner($Cocoon Mound)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

3. `ActivateGameObject(gameObject="Owner($Trap Cocoons)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`



#### Return In · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:529106>)

出口：FINISHED → Roar。isSequence=0。

1. `AudioStop(gameObject="Owner($Sound Player)", fadeTime=0)`

2. `SetIsKinematic2d(gameObject="Self", isKinematic=1)`

3. `AudioStop(gameObject="Owner($Sound Player)", fadeTime=0)`

4. `SetPosition(gameObject="Self", vector="None", x=7.87, y=5, z="None", space=1, everyFrame=false, lateUpdate=false)`

5. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:a494cbac2a5d26f4885070238d5d72ec#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

6. `PlayParticleEmitter(gameObject="Owner($Pt Idle)", emit=0, resetIfPlaying=false)`

7. `SetInvincible(target="Self", Invincible=0, InvincibleFromDirection=0, resetOnStateExit=false)`

8. `PlayParticleEmitter(gameObject="Owner($Appear Rubble)", emit=0, resetIfPlaying=false)`

9. `SetFsmBool(gameObject="Owner($CameraParent)", fsmName="CameraShake", variableName="RumblingMed", setValue=0, everyFrame=false)`

10. `SetScale(gameObject="Self", vector="None", x=-1, y="None", z="None", everyFrame=false, lateUpdate=false)`

11. `ActivateGameObject(gameObject="Owner($Cocoon)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

12. `SetMeshRenderer(gameObject="Self", active=1)`

13. `SetVelocity2d(gameObject="Self", vector="None", x="None", y=-30, everyFrame=false)`

14. `Wait(time=0.75, finishEvent="FINISHED", realTime=false)`

15. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Antic")`

16. `DecelerateXY(gameObject="Self", decelerationX="None", decelerationY=0.9, brakeOnExit=false)`

17. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($CameraParent)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="BigShake", delay=0, everyFrame=false)`

18. `PlayParticleEmitterInState(gameObject="Owner($Pt Dust)")`



#### Return Pause · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:529662>)

出口：FINISHED → Return Antic。isSequence=0。

1. `Wait(time=1, finishEvent="FINISHED", realTime=false)`



#### Return Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:529735>)

出口：FINISHED → Return In。isSequence=0。

1. `Wait(time=1.8, finishEvent="FINISHED", realTime=false)`

2. `SetFsmBool(gameObject="Owner($CameraParent)", fsmName="CameraShake", variableName="RumblingMed", setValue=1, everyFrame=false)`

3. `PlayParticleEmitterInState(gameObject="Owner($Shake Drip)")`

4. `PlayParticleEmitterInState(gameObject="Owner($Shake Rubble)")`

5. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Hero", audioClip="GUID:9cf29171e309dee4ea00de9b3dbd6c6e#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="$Sound Player")`

6. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Hero", audioClip="GUID:004107fb86f721d428d7e88acd991bef#8300000", pitchMin=0.8, pitchMax=0.8, volume=1, delay=0, storePlayer="fileID:0")`



#### Reduce Idle Time · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:529981>)

出口：FINISHED → Anim End 2。isSequence=0。

1. `SetFloatValue(floatVariable="$Idle Time", floatValue=0.5, everyFrame=false)`

2. `SetFloatValue(floatVariable="$Recover Time", floatValue=0.25, everyFrame=false)`



#### Reduce Idle Time 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:530076>)

出口：FINISHED → Slam Antic。isSequence=0。

1. `FloatCompare(float1="$Idle Time", float2=1, tolerance=0, equal=null, lessThan="FINISHED", greaterThan=null, everyFrame=false)`

2. `SetFloatValue(floatVariable="$Idle Time", floatValue=1, everyFrame=false)`



#### Check Hero in Room · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:530184>)

出口：FINISHED → Start Battle。isSequence=0。

1. `GetPosition(gameObject="Owner($Hero)", vector="None", x="$X Pos", y="None", z="None", space=0, everyFrame=true)`

2. `FloatInRange(floatVariable="$X Pos", lowerValue=45.08, upperValue=69.05, boolVariable="None", trueEvent="FINISHED", falseEvent=null, everyFrame=true)`



#### Sing Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:530321>)

出口：FINISHED → Sing。isSequence=0。

1. `DecelerateV2(gameObject="Self", deceleration=0.85, brakeOnExit=false)`

2. `FadeAudio(gameObject="Self", startVolume=1, endVolume=0, time=0.3)`

3. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Antic", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

4. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

5. `Wait(time=0.2, finishEvent="FINISHED", realTime=false)`



#### Sing · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:530503>)

出口：END → Recover；SING DURATION END → Recover。isSequence=0。

1. `DecelerateV2(gameObject="Self", deceleration=0.9, brakeOnExit=true)`

2. `EnemySingControl(enemyGameObject="Self", audioPlayer="$Audio Loop Voice", singAudioTable="GUID:ce4acd3823b304841900af86ceff75ce#11400000", noThreadEffects=0, noPuppetString=0, randomSingStartTime=0, dontStopAudioOnExit=0, altThreadSpawnPoint="fileID:0")`

3. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Roar")`

4. `CheckHeroPerformanceRegionV2(Target="Self", Radius=10, MinReactDelay=0.3, MaxReactDelay=0.4, None="END", ActiveInner=null, ActiveOuter=null, IgnoreNeedolinRange=1, UseActiveBool=0, ActiveBool="None", StoreState="None", EveryFrame=true)`

5. `SendEventToRegister(eventName="MOSS SONG START")`

6. `ShoveFromWall(gameObject="Self", shoveForce=10, rayLength=2, checkUp=true, checkDown=true, checkLeft=true, checkRight=true, everyFrame=true)`



#### Recover · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:530785>)

出口：FINISHED → Idle。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Recover", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `SendEventToRegister(eventName="MOSS SONG END")`



#### Damage Timer · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:530877>)

出口：FINISHED → Idle。isSequence=0。

1. `FloatAdd(floatVariable="$Timer", add=0.75, everyFrame=false, perSecond=false)`



#### Stun Start · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:530956>)

出口：FINISHED → Stunned。isSequence=0。

1. `StopParticleEmitter(gameObject="Owner($Pt Slam)")`

2. `StopParticleEmitter(gameObject="Owner($Pt SwoopDust)")`

3. `StopParticleEmitter(gameObject="Owner($Pt SwoopRock)")`

4. `SetRecoilSpeed(target="Self", newRecoilSpeed=2)`

5. `SetFloatValue(floatVariable="$Stun Timer", floatValue=2, everyFrame=false)`

6. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

7. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Stun")`

8. `SendEventToRegister(eventName="MOSS SONG END")`

9. `SetRecoilBlocked(Target="Self", IsUpBlocked=0, IsDownBlocked=0, IsLeftBlocked=0, IsRightBlocked=0)`

10. `AudioPlayRandomVoiceFromTable(gameObject="Owner($Audio Loop Voice)", audioClipTable="GUID:833f83d3c1054994598cf59ae3accd4e#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`



#### Stunned · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:531216>)

出口：END → Stun Recover；TOOK DAMAGE → Stun Damage。isSequence=0。

1. `DecelerateXY(gameObject="Self", decelerationX=0.85, decelerationY="None", brakeOnExit=false)`

2. `FloatAdd(floatVariable="$Stun Timer", add=-1, everyFrame=true, perSecond=true)`

3. `FloatCompare(float1="$Stun Timer", float2=0, tolerance=0, equal="END", lessThan="END", greaterThan=null, everyFrame=true)`

4. `IdleBuzzV3(gameObject="Self", waitMin=0.5, waitMax=0.75, speedMax=2, accelerationMin=30, accelerationMax=30, roamingRangeX=0.25, roamingRangeY=0.25, manualStartPos="None")`



#### Stun Damage · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:531427>)

出口：FINISHED → Stunned；END → Damage Recover。isSequence=0。

1. `AudioPlayRandomVoiceFromTable(gameObject="Owner($Audio Loop Voice)", audioClipTable="GUID:833f83d3c1054994598cf59ae3accd4e#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`

2. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

3. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Stun Hit")`

4. `Tk2dPlayFrame(gameObject="Self", frame=0)`

5. `FloatAdd(floatVariable="$Stun Timer", add=-0.1, everyFrame=false, perSecond=false)`

6. `FloatCompare(float1="$Stun Timer", float2=0, tolerance=0, equal="END", lessThan="END", greaterThan="FINISHED", everyFrame=false)`



#### Damage Recover · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:531646>)

出口：FINISHED → Stun Recover。isSequence=0。

1. `SendEventByName(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="EnemyKillShake", delay=0, everyFrame=false)`

2. `SendMessage(gameObject="Owner($GameManager)", delivery=0, options=1, functionCall={"FunctionName":"FreezeMoment","parameterType":"int","BoolParameter":0,"FloatParameter":0,"IntParameter":1,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`



#### Stun Recover · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:531894>)

出口：FINISHED → Idle。isSequence=0。

1. `SetRecoilSpeed(target="Self", newRecoilSpeed=5)`

2. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="STUN CONTROL START", delay=0, everyFrame=false)`

3. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Recover", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`



#### 2nd Crawler · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:532045>)

出口：FINISHED → Crawler。isSequence=0。

1. `BoolTest(boolVariable="$Done First Spawn", isTrue=null, isFalse="FINISHED", everyFrame=false)`

2. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Spawn Crawler 2)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="SPAWN", delay=0, everyFrame=false)`



#### Extract · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:532170>)

出口：EXTRACT FINISH → Extract Hit。isSequence=0。

1. `EnemyDeathEffectsRegular+SimulateDeath(target="Self")`

2. `GetPosition(gameObject="Self", vector="None", x="None", y="None", z="$Z Pos", space=0, everyFrame=false)`

3. `SetVelocity2d(gameObject="Self", vector={"x":0,"y":0}, x="None", y="None", everyFrame=false)`

4. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Roar")`

5. `FindChild(gameObject="Owner($Hero)", childName="Tool Effects/Extract Point", storeResult="$Extract Point")`

6. `GetPosition2D(gameObject="Owner($Extract Point)", vector="$Extract pos", x="None", y="None", space=0, everyFrame=false)`

7. `Vector2AddXY(vector2Variable="$Extract pos", addX="$Offset", addY=0.5, everyFrame=false, perSecond=false)`

8. `GetPosition(gameObject="Self", vector="None", x="None", y="None", z="$Z Pos", space=0, everyFrame=false)`

9. `SendMessage(gameObject="Self", delivery=0, options=1, functionCall={"FunctionName":"FlashingMossExtract","parameterType":"None","BoolParameter":0,"FloatParameter":0,"IntParameter":0,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`

10. `SetPosition(gameObject="Self", vector="None", x="None", y="None", z=0.003, space=0, everyFrame=false, lateUpdate=false)`

11. `AnimateRigidBody2DPositionTo(GameObject="Self", ToValue="$Extract pos", time=0.2, speed="None", delay="None", easeType=13, reverse=0, finishEvent=null, realTime=false)`

12. `SetDamageHero(Target="Self", Enabled=0)`



#### Extract Hit · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:532713>)

出口：FINISHED → Recover。isSequence=0。

1. `SubtractHP(target="Self", amount=20)`

2. `SetDamageHero(Target="Self", Enabled=1)`

3. `EnemyDeathEffectsRegular+SimulateDeath(target="Self")`

4. `SendMessage(gameObject="Self", delivery=0, options=1, functionCall={"FunctionName":"CancelFlash","parameterType":"None","BoolParameter":0,"FloatParameter":0,"IntParameter":0,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`

5. `SetVelocity2d(gameObject="Self", vector="None", x="$Recoil Speed", y="None", everyFrame=false)`



#### Get Dir · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:532991>)

出口：FINISHED → Extract。isSequence=0。

1. `SetFloatValue(floatVariable="$Offset", floatValue=-0.25, everyFrame=false)`

2. `SetFloatValue(floatVariable="$Recoil Dir", floatValue=180, everyFrame=false)`

3. `SetFloatValue(floatVariable="$Recoil Speed", floatValue=-10, everyFrame=false)`

4. `CheckTargetDirection(gameObject="Self", target="$Hero", aboveEvent=null, belowEvent=null, rightEvent="FINISHED", leftEvent=null, aboveBool="None", belowBool="None", rightBool="None", leftBool="None", selfOffsetX=0, selfOffsetY=0, reverseIfNegativeScale=false, everyFrame=false)`

5. `SetFloatValue(floatVariable="$Offset", floatValue=0.25, everyFrame=false)`

6. `SetFloatValue(floatVariable="$Recoil Dir", floatValue=0, everyFrame=false)`

7. `SetFloatValue(floatVariable="$Recoil Speed", floatValue=10, everyFrame=false)`



#### Check First Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:533224>)

出口：FINISHED → Move Choice。isSequence=0。

1. `FloatCompare(float1="$Idle Time", float2=1.5, tolerance=0, equal="FINISHED", lessThan="FINISHED", greaterThan=null, everyFrame=false)`

2. `SetFloatValue(floatVariable="$Idle Time", floatValue=1.5, everyFrame=false)`



#### Return Ready 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:533332>)

出口：BATTLE START → Return Pause 2。isSequence=0。

1. `GetPosition2D(gameObject="Self", vector="$Entry Pos Double", x="None", y="None", space=0, everyFrame=false)`

2. `SetPosition(gameObject="Self", vector="None", x="None", y=99, z="None", space=0, everyFrame=false, lateUpdate=false)`

3. `ActivateGameObject(gameObject="Owner($Cocoon Mound)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

4. `ActivateGameObject(gameObject="Owner($Trap Cocoons)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

5. `SetFloatValue(floatVariable="$Idle Time", floatValue=0.5, everyFrame=false)`

6. `SetFloatValue(floatVariable="$Recover Time", floatValue=0.25, everyFrame=false)`

7. `SetFloatValue(floatVariable="$Max Height", floatValue=25, everyFrame=false)`



#### Return In 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:533574>)

出口：FINISHED → Roar。isSequence=0。

1. `AudioStop(gameObject="Owner($Sound Player)", fadeTime=0)`

2. `SetIsKinematic2d(gameObject="Self", isKinematic=1)`

3. `AudioStop(gameObject="Owner($Sound Player)", fadeTime=0)`

4. `SetPosition2D(GameObject="Self", Vector="$Entry Pos Double", X=0, Y=0, Space=0, EveryFrame=false)`

5. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:a494cbac2a5d26f4885070238d5d72ec#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

6. `PlayParticleEmitter(gameObject="Owner($Pt Idle)", emit=0, resetIfPlaying=false)`

7. `SetInvincible(target="Self", Invincible=0, InvincibleFromDirection=0, resetOnStateExit=false)`

8. `PlayParticleEmitter(gameObject="Owner($Appear Rubble)", emit=0, resetIfPlaying=false)`

9. `SetFsmBool(gameObject="Owner($CameraParent)", fsmName="CameraShake", variableName="RumblingMed", setValue=0, everyFrame=false)`

10. `ActivateGameObject(gameObject="Owner($Cocoon)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

11. `SetMeshRenderer(gameObject="Self", active=1)`

12. `SetVelocity2d(gameObject="Self", vector="None", x="None", y=-30, everyFrame=false)`

13. `Wait(time=0.75, finishEvent="FINISHED", realTime=false)`

14. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Antic")`

15. `DecelerateXY(gameObject="Self", decelerationX="None", decelerationY=0.9, brakeOnExit=false)`

16. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($CameraParent)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="BigShake", delay=0, everyFrame=false)`

17. `PlayParticleEmitterInState(gameObject="Owner($Pt Dust)")`



#### Return Pause 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:534081>)

出口：FINISHED → Return Antic 2。isSequence=0。

1. `Wait(time=1, finishEvent="FINISHED", realTime=false)`



#### Return Antic 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:534154>)

出口：FINISHED → Return In 2。isSequence=0。

1. `Wait(time=2, finishEvent="FINISHED", realTime=false)`

2. `SetFsmBool(gameObject="Owner($CameraParent)", fsmName="CameraShake", variableName="RumblingMed", setValue=1, everyFrame=false)`

3. `PlayParticleEmitterInState(gameObject="Owner($Shake Drip)")`

4. `PlayParticleEmitterInState(gameObject="Owner($Shake Rubble)")`

5. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Hero", audioClip="GUID:9cf29171e309dee4ea00de9b3dbd6c6e#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="$Sound Player")`



#### Move Choice D · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:534341>)

出口：SWOOP → Swoop Antic；SLAM → Slam Antic。isSequence=0。

1. `SendRandomEventV2(events=["SLAM","SWOOP"], weights=[1,1], trackingInts=["$Ct Slam","$Ct Swoop"], eventMax=[2,2])`



#### Drop Type 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:534467>)

出口：CRAWLER → 2nd Crawler；ROCK → Rock；BUDDY → Do Call Buddy。isSequence=0。

1. `GetHP(target="Self", storeValue="$HP")`

2. `IntTestToBool(int1="$HP", int2="$HP Call Buddy", equalBool="None", lessThanBool="$Ready To Call", greaterThanBool="None", everyFrame=false)`

3. `BoolTestMulti(boolVariables=["$Called Buddy","$Ready To Call","$Double Fight Buddy"], boolStates=[0,1,0], trueEvent="BUDDY", falseEvent=null, storeResult="None", everyFrame=false)`

4. `SendRandomEventV2(events=["ROCK","CRAWLER"], weights=[1,1], trackingInts=["$Ct Rock","$Ct Crawler"], eventMax=[1,1])`



#### Buddy · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:534718>)

出口：CALL BUDDY → Entry Antic。isSequence=0。

1. `GetPosition2D(gameObject="Self", vector="$Entry Pos Double", x="None", y="None", space=0, everyFrame=false)`

2. `SetPosition(gameObject="Self", vector="None", x="None", y=99, z="None", space=0, everyFrame=false, lateUpdate=false)`

3. `ActivateGameObject(gameObject="Owner($Cocoon Mound)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

4. `ActivateGameObject(gameObject="Owner($Trap Cocoons)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

5. `SetFloatValue(floatVariable="$Idle Time", floatValue=0.5, everyFrame=false)`

6. `SetFloatValue(floatVariable="$Recover Time", floatValue=0.25, everyFrame=false)`

7. `SetBoolValue(boolVariable="$Double Fight", boolValue=1, everyFrame=false)`

8. `SetIsKinematic2d(gameObject="Self", isKinematic=1)`

9. `ActivateGameObject(gameObject="Owner($Cocoon)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

10. `SetMeshRenderer(gameObject="Self", active=0)`

11. `SetCollider(gameObject="Self", active=0, resetOnExit=false)`

12. `SetFloatValue(floatVariable="$Max Height", floatValue=25, everyFrame=false)`



#### Entry Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:535059>)

出口：FINISHED → Return In 3。isSequence=0。

1. `Wait(time=2, finishEvent="FINISHED", realTime=false)`

2. `SetPosition2D(GameObject="Self", Vector="$Entry Pos Double", X=0, Y=0, Space=0, EveryFrame=false)`

3. `PlayParticleEmitterChildren(gameObject="Owner($Pt BuddyEntryAntic)", resetTimeIfPlaying=false, stopOnStateExit=true)`

4. `PlayParticleEmitterInState(gameObject="Owner($Shake Drip)")`

5. `PlayParticleEmitterInState(gameObject="Owner($Shake Rubble)")`

6. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Hero", audioClip="GUID:9cf29171e309dee4ea00de9b3dbd6c6e#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="$Sound Player")`



#### Return In 3 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:535260>)

出口：FINISHED → Roar 2。isSequence=0。

1. `AudioStop(gameObject="Owner($Sound Player)", fadeTime=0)`

2. `SetIsKinematic2d(gameObject="Self", isKinematic=1)`

3. `AudioStop(gameObject="Owner($Sound Player)", fadeTime=0)`

4. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:a494cbac2a5d26f4885070238d5d72ec#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

5. `PlayParticleEmitter(gameObject="Owner($Pt Idle)", emit=0, resetIfPlaying=false)`

6. `SetInvincible(target="Self", Invincible=0, InvincibleFromDirection=0, resetOnStateExit=false)`

7. `PlayParticleEmitter(gameObject="Owner($Appear Rubble)", emit=0, resetIfPlaying=false)`

8. `SetFsmBool(gameObject="Owner($CameraParent)", fsmName="CameraShake", variableName="RumblingMed", setValue=0, everyFrame=false)`

9. `ActivateGameObject(gameObject="Owner($Cocoon)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

10. `SetMeshRenderer(gameObject="Self", active=1)`

11. `SetVelocity2d(gameObject="Self", vector="None", x="None", y=-30, everyFrame=false)`

12. `Wait(time=0.75, finishEvent="FINISHED", realTime=false)`

13. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Antic")`

14. `DecelerateXY(gameObject="Self", decelerationX="None", decelerationY=0.9, brakeOnExit=false)`

15. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($CameraParent)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="BigShake", delay=0, everyFrame=false)`

16. `PlayParticleEmitterInState(gameObject="Owner($Pt Dust)")`

17. `SetCollider(gameObject="Self", active=1, resetOnExit=false)`



#### Do Call Buddy · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:535752>)

出口：FINISHED → Reduce Idle Time。isSequence=0。

1. `SetBoolValue(boolVariable="$Called Buddy", boolValue=1, everyFrame=false)`

2. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Parent)","fsmName":null,"sendToChildren":1,"fsmComponent":"fileID:0"}, sendEvent="CALL BUDDY", delay=0, everyFrame=false)`



#### Roar End 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:535880>)

出口：FINISHED → Idle。isSequence=0。

1. `SetInvincible(target="Self", Invincible=0, InvincibleFromDirection=0, resetOnStateExit=false)`

2. `ActivateGameObject(gameObject="Owner($Terrain Block)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

3. `SetCollider(gameObject="Self", active=1, resetOnExit=false)`



#### Roar 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:536013>)

出口：FINISHED → Roar End 2。isSequence=0。

1. `SetAudioSource(gameObject="Self", active=1)`

2. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:75fcdd74fbd52b243ad4b7657b22eee3#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

3. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:7b31832c38310bd469ae8734210fb9f7#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

4. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:cadfc16ee055c944da51081b220f0a1a#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

5. `SetIsKinematic2d(gameObject="Self", isKinematic=0)`

6. `Wait(time=1, finishEvent="FINISHED", realTime=false)`

7. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Roar")`

8. `SetVelocity2d(gameObject="Self", vector={"x":0,"y":0}, x="None", y="None", everyFrame=false)`

9. `StartRoarEmitter(spawnPoint="Self", delay=0, stunHero=0, roarBurst=1, isSmall=0, noVisualEffect=0, forceThroughBind=0, stopOnExit=false)`

10. `PlayParticleEmitter(gameObject="Owner($Pt Roar)", emit=0, resetIfPlaying=false)`

11. `DoCameraShake(VisibleRenderer="Owner(fileID:0)", Camera="GUID:9b0888e0916dca544846a2f34304dac9#11400000", Profile="GUID:bcadf15120fe09e41b0ab53ed04fe6a4#11400000", cancelOnExit=false, DoFreeze=0, Delay=0)`



#### Double End · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:536472>)

出口：无本地迁移（持续/外部驱动）。isSequence=0。

1. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Parent)","fsmName":null,"sendToChildren":1,"fsmComponent":"fileID:0"}, sendEvent="CALL BUDDY", delay=0, everyFrame=false)`



#### Set Antic Dir · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:536574>)

出口：FINISHED → Slam Antic 2。isSequence=0。

1. `SetVector2Value(vector2Variable="$Slam Antic Vector", vector2Value={"x":0,"y":-8}, everyFrame=false)`

2. `BoolTest(boolVariable="$Double Fight", isTrue=null, isFalse="FINISHED", everyFrame=false)`

3. `CheckXPosition(gameObject="Self", compareTo=24, compareToOffset=0, tolerance=0, equal=null, equalBool="None", lessThan="FINISHED", lessThanBool="None", greaterThan=null, greaterThanBool="None", everyFrame=false, space=0, activeBool="None")`

4. `SetVector2Value(vector2Variable="$Slam Antic Vector", vector2Value={"x":-15,"y":-8}, everyFrame=false)`



#### Dmg Response · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:536751>)

出口：FINISHED → Check First Idle。isSequence=0。

1. `FaceObject(objectA="$Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=true, newAnimationClip="TurnToFly", resetFrame=true, everyFrame=true)`

2. `DistanceFlyV2(gameObject="Self", target="$Hero", distance=12, speedMax=6, acceleration=0.375, targetsHeight=true, height=6, maxHeight="$Max Height", stayLeft="None", stayRight="None")`

3. `WaitRandom(timeMin=0.25, timeMax=0.4, finishEvent="FINISHED", realTime=false)`



#### Idle D · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:536932>)

出口：NEEDOLIN → Sing Antic；TOOK DAMAGE → Dmg Response；WAIT → Check First Idle。isSequence=0。

1. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Fly")`

2. `FaceObject(objectA="$Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=true, newAnimationClip="TurnToFly", resetFrame=true, everyFrame=true)`

3. `GetPosition(gameObject="Owner($Hero)", vector="None", x="$Hero X", y="None", z="None", space=0, everyFrame=true)`

4. `FloatTestToBool(float1="$Hero X", float2="$Centre X", tolerance=0, equalBool="None", lessThanBool="$Hero Left", greaterThanBool="$Hero Right", everyFrame=true)`

5. `DistanceFlyV2(gameObject="Self", target="$Hero", distance=12, speedMax=6, acceleration=0.375, targetsHeight=true, height=6, maxHeight="$Max Height", stayLeft="$z Always Stay Left", stayRight="$z Always Stay Right")`

6. `CheckHeroPerformanceRegion(Target="Self", MinReactDelay=0.1, MaxReactDelay=0.25, None=null, ActiveInner="NEEDOLIN", ActiveOuter=null, IgnoreNeedolinRange=1, useActiveBool=false, ActiveBool="None", StoreState="None", EveryFrame=true)`

7. `FloatAdd(floatVariable="$Timer", add=1, everyFrame=true, perSecond=true)`

8. `FloatCompare(float1="$Timer", float2="$Idle Time", tolerance=0, equal="WAIT", lessThan=null, greaterThan="WAIT", everyFrame=true)`



#### Rock - DB · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:537326>)

出口：FINISHED → Anim End。isSequence=0。

1. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Stals)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="FALL", delay=0, everyFrame=false)`



#### Reset Bind Prompt? · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:537437>)

出口：FINISHED → Roar End。isSequence=0。

1. `PlayerDataBoolTest(boolName="completedTutorial", isTrue="FINISHED", isFalse=null)`

2. `SetPlayerDataBool(boolName="SeenBindPrompt", value=0)`



### Shake Drip / Final Boom [external_linked_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:443752>)

变量初值：`{}`

全局迁移：`[]`

#### State 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:443769>)

出口：BOOM → State 2。isSequence=0。



#### State 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:443830>)

出口：FINISHED → State 3。isSequence=0。

1. `PlayParticleEmitterInState(gameObject="Self")`

2. `Wait(time=1, finishEvent="FINISHED", realTime=false)`



#### State 3 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:443914>)

出口：无本地迁移（持续/外部驱动）。isSequence=0。



### Battle Scene / Re-Encounter [external_linked_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:446100>)

变量初值：`{}`

全局迁移：`[]`

#### State 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:446117>)

出口：FINISHED → State 2。isSequence=0。

1. `NextFrameEvent(sendEvent="FINISHED")`



#### State 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:446182>)

出口：RE ENCOUNTER → State 3。isSequence=0。

1. `PlayerDataBoolTest(boolName="encounteredMossMother", isTrue="RE ENCOUNTER", isFalse=null)`



#### State 3 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:446256>)

出口：无本地迁移（持续/外部驱动）。isSequence=0。

1. `SetCollider(gameObject="Self", active=1, resetOnExit=false)`



### Shake Rubble / Final Boom [external_linked_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:466515>)

变量初值：`{}`

全局迁移：`[]`

#### State 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:466532>)

出口：BOOM → State 2。isSequence=0。



#### State 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:466593>)

出口：FINISHED → State 3。isSequence=0。

1. `PlayParticleEmitterInState(gameObject="Self")`

2. `Wait(time=1, finishEvent="FINISHED", realTime=false)`



#### State 3 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:466677>)

出口：无本地迁移（持续/外部驱动）。isSequence=0。



### MossBone Crawler Summon (1) / Summon Control [external_linked_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:472820>)

变量初值：`{"floatVariables":{"Death Speed":0,"Spawn X":0,"SpawnX 1":0.65,"SpawnX 2":0.65,"Kill Angle":0,"Offset":0,"Rotation":0,"Z Pos":0,"Spawn Y":0},"gameObjectVariables":{"Antic Dust":{"fileID":0},"Antic Rocks":{"fileID":0},"Mother":{"fileID":1593},"Self":{"fileID":0},"Hero":{"fileID":0},"Extract Point":{"fileID":0},"Audio Loop Voice":{"fileID":1872}}}`

全局迁移：`[{"fsmEvent":{"name":"EXTRACT","isSystemEvent":0,"isGlobal":0},"toState":"Extract","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0},{"fsmEvent":{"name":"ZERO HP","isSystemEvent":0,"isGlobal":0},"toState":"Corpse Away","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0},{"fsmEvent":{"name":"CRUSH","isSystemEvent":0,"isGlobal":0},"toState":"Crush Death","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0},{"fsmEvent":{"name":"BOSS BATTLE END","isSystemEvent":0,"isGlobal":0},"toState":"Corpse Away","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0}]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:472837>)

出口：FINISHED → Dormant。isSequence=0。

1. `FindChild(gameObject="Self", childName="Antic Dust", storeResult="$Antic Dust")`

2. `FindChild(gameObject="Self", childName="Antic Rocks", storeResult="$Antic Rocks")`

3. `GetOwner(storeGameObject="$Self")`

4. `GetHero(storeResult="$Hero")`

5. `GetPosition2D(gameObject="Self", vector="None", x="None", y="$Spawn Y", space=1, everyFrame=false)`

6. `EnableFSM(gameObject="Self", fsmName="Noise Reaction", enable=0, resetOnExit=0)`



#### Dormant · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:473032>)

出口：SPAWN → Spawn Pause。isSequence=0。

1. `SetPosition2d(gameObject="Self", vector="None", x=-100, y="None", space=0, everyFrame=false, lateUpdate=false)`



#### Position · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:473128>)

出口：FINISHED → Antic；BOSS KILL → Die。isSequence=0。

1. `RandomFloatEither(value1="$SpawnX 1", value2="$SpawnX 2", storeResult="$Spawn X")`

2. `SetPosition(gameObject="Self", vector="None", x="$Spawn X", y="$Spawn Y", z="None", space=1, everyFrame=false, lateUpdate=false)`

3. `SetHP(target="Self", hp=10)`



#### Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:473281>)

出口：NEXT → Fall；BOSS KILL → Die。isSequence=0。

1. `PlayParticleEmitterInState(gameObject="Owner($Antic Dust)")`

2. `PlayParticleEmitterInState(gameObject="Owner($Antic Rocks)")`

3. `Wait(time=0.75, finishEvent="NEXT", realTime=false)`

4. `AudioPlayerOneShot(audioPlayer="GUID:e8466d04a5c03bc4b8d6a0838af84de7#1709254077376921", spawnPoint="$Self", audioClips=["GUID:b47c68feccbc0c84b9562417f526f00e#8300000","GUID:95b9cb4101bbbd24c92ddca266151d34#8300000","GUID:a42edaf49998bc24bb2012762bff4f67#8300000"], weights=[1,1,1], pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Fall · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:473467>)

出口：LAND → Bounce；BOSS KILL → Corpse Away。isSequence=0。

1. `SetCollider(gameObject="Self", active=1, resetOnExit=false)`

2. `FaceObject(objectA="$Self", objectB="$Hero", spriteFacesRight=0, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false)`

3. `SetIsKinematic2d(gameObject="Self", isKinematic=0)`

4. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="SummonFall")`

5. `SetMeshRenderer(gameObject="Self", active=1)`

6. `CheckCollisionSideEnter(topHit="None", rightHit="None", bottomHit="None", leftHit="None", topHitEvent=null, rightHitEvent=null, bottomHitEvent="LAND", leftHitEvent=null, otherLayer=false, otherLayerNumber=0, ignoreTriggers=0)`

7. `CheckCollisionSide(collidingObject="Self", topHit="None", rightHit="None", bottomHit="None", leftHit="None", topHitEvent=null, rightHitEvent=null, bottomHitEvent="LAND", leftHitEvent=null, otherLayer=false, otherLayerNumber=0, ignoreTriggers=0)`



#### Land · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:473753>)

出口：FINISHED → Move；BOSS KILL → Corpse Away。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="SummonLand", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `FaceObject(objectA="$Self", objectB="$Hero", spriteFacesRight=0, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false)`



#### Move · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:473878>)

出口：BOSS KILL → Corpse Away。isSequence=0。

1. `EnableFSM(gameObject="Self", fsmName="Noise Reaction", enable=1, resetOnExit=1)`

2. `StartCrawler(Target="Self", ScheduleTurn=0)`

3. `AudioPlayInState(gameObject="Self", volume=1)`



#### Die · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:474007>)

出口：FINISHED → Dormant。isSequence=0。

1. `SetIsKinematic2d(gameObject="Self", isKinematic=1)`

2. `SetVelocity2d(gameObject="Self", vector={"x":0,"y":0}, x="None", y="None", everyFrame=false)`

3. `SetMeshRenderer(gameObject="Self", active=0)`



#### Corpse Away · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:474137>)

出口：FINISHED → Die。isSequence=0。

1. `EnemyDeathEffectsRegular+SimulateDeath(target="Self")`

2. `SetFsmBool(gameObject="Owner($Mother)", fsmName="Control", variableName="Spawned", setValue=0, everyFrame=false)`

3. `AudioPlayRandomVoiceFromTable(gameObject="Owner($Audio Loop Voice)", audioClipTable="GUID:c98e975e288d3034f95c45c8f5a2202c#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`

4. `FaceObject(objectA="$Self", objectB="$Hero", spriteFacesRight=0, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false)`

5. `SetCollider(gameObject="Self", active=0, resetOnExit=false)`

6. `StopCrawler(Target="Self", WaitForTurn=0)`

7. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Death Air")`

8. `GetScale(gameObject="Self", vector="None", xScale="$Death Speed", yScale="None", zScale="None", space=0, everyFrame=false)`

9. `FloatMultiply(floatVariable="$Death Speed", multiplyBy=5, everyFrame=false)`

10. `SetVelocity2d(gameObject="Self", vector="None", x="$Death Speed", y=20, everyFrame=false)`

11. `Wait(time=1, finishEvent="FINISHED", realTime=false)`

12. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($CameraParent)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="EnemyKillShake", delay=0, everyFrame=false)`

13. `SendMessage(gameObject="Owner($GameManager)", delivery=0, options=1, functionCall={"FunctionName":"FreezeMoment","parameterType":"int","BoolParameter":0,"FloatParameter":0,"IntParameter":1,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`



#### Bounce · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:474649>)

出口：FINISHED → BounceUp；BOSS KILL → Corpse Away。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="SummonBounce", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `AudioPlayRandomVoiceFromTable(gameObject="Owner($Audio Loop Voice)", audioClipTable="GUID:18fd8b755d8e99a44bb0ae3d1aaf0efa#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`

3. `AudioPlayerOneShot(audioPlayer="GUID:e8466d04a5c03bc4b8d6a0838af84de7#1709254077376921", spawnPoint="$Self", audioClips=["GUID:8df438dfd759e3d40af7d126886e748e#8300000","GUID:5838a93b99a327a4cae5a65a8dfcef21#8300000","GUID:edbab5cc3b71ce94faa79211ddc56b6e#8300000"], weights=[1,1,1], pitchMin=1.15, pitchMax=1.25, volume=1, delay=0, storePlayer="fileID:0")`



#### BounceUp · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:474845>)

出口：FINISHED → BounceFall；BOSS KILL → Corpse Away。isSequence=0。

1. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="SummonFall")`

2. `RandomFloat(min=9, max=12, storeResult="None")`

3. `SetVelocity2d(gameObject="Self", vector="None", x="None", y=9, everyFrame=false)`

4. `NextFrameEvent(sendEvent="FINISHED")`



#### BounceFall · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:475000>)

出口：BOSS KILL → Corpse Away；LAND → Land。isSequence=0。

1. `CheckCollisionSideEnter(topHit="None", rightHit="None", bottomHit="None", leftHit="None", topHitEvent=null, rightHitEvent=null, bottomHitEvent="LAND", leftHitEvent=null, otherLayer=false, otherLayerNumber=0, ignoreTriggers=0)`

2. `CheckCollisionSide(collidingObject="Self", topHit="None", rightHit="None", bottomHit="None", leftHit="None", topHitEvent=null, rightHitEvent=null, bottomHitEvent="LAND", leftHitEvent=null, otherLayer=false, otherLayerNumber=0, ignoreTriggers=0)`



#### Spawn Pause · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:475173>)

出口：FINISHED → Position。isSequence=0。

1. `WaitRandom(timeMin=0, timeMax=0.5, finishEvent="FINISHED", realTime=false)`



#### Extract · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:475253>)

出口：EXTRACT FINISH → Extract End。isSequence=0。

1. `EnemyDeathEffectsRegular+SimulateDeath(target="Self")`

2. `StopCrawler(Target="Self", WaitForTurn=0)`

3. `SetVelocity2d(gameObject="Self", vector={"x":0,"y":0}, x="None", y="None", everyFrame=false)`

4. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Extract")`

5. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=0, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

6. `SetCollider(gameObject="Self", active=0, resetOnExit=false)`

7. `SetIsKinematic2d(gameObject="Self", isKinematic=1)`

8. `GetScale(gameObject="Self", vector="None", xScale="$Rotation", yScale="None", zScale="None", space=0, everyFrame=false)`

9. `GetScale(gameObject="Self", vector="None", xScale="$Offset", yScale="None", zScale="None", space=0, everyFrame=false)`

10. `FloatMultiply(floatVariable="$Rotation", multiplyBy=-90, everyFrame=false)`

11. `FloatMultiply(floatVariable="$Offset", multiplyBy=0.25, everyFrame=false)`

12. `SetRotation(gameObject="Self", quaternion="None", vector="None", xAngle="None", yAngle="None", zAngle="$Rotation", space=0, everyFrame=false, lateUpdate=false)`

13. `FindChild(gameObject="Owner($Hero)", childName="Tool Effects/Extract Point", storeResult="$Extract Point")`

14. `GetPosition(gameObject="Self", vector="None", x="None", y="None", z="$Z Pos", space=0, everyFrame=false)`

15. `SetPositionToObject(gameObject="Self", targetObject="$Extract Point", xOffset="$Offset", yOffset=0, zOffset="None", overrideZ=0.003, everyFrame=false)`

16. `SendMessage(gameObject="Self", delivery=0, options=1, functionCall={"FunctionName":"FlashingMossExtract","parameterType":"None","BoolParameter":0,"FloatParameter":0,"IntParameter":0,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`



#### Extract End · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:475889>)

出口：FINISHED → Corpse Away。isSequence=0。

1. `SendMessage(gameObject="Self", delivery=0, options=1, functionCall={"FunctionName":"CancelFlash","parameterType":"None","BoolParameter":0,"FloatParameter":0,"IntParameter":0,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`

2. `SetIsKinematic2d(gameObject="Self", isKinematic=0)`



#### Crush Death · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:476105>)

出口：FINISHED → Die。isSequence=0。

1. `PlayAudioEvent(audioClip="GUID:d921724037ad76c429becd63cb4c9677#8300000", pitchMin=1, pitchMax=1, volume=1, audioPlayerPrefab="None", spawnPoint="Self", spawnPosition={"x":0,"y":0,"z":0}, SpawnedPlayerRef="None")`

2. `EnemyDeathEffectsRegular+SimulateDeath(target="Self")`

3. `SetFsmBool(gameObject="Owner($Mother)", fsmName="Control", variableName="Spawned", setValue=0, everyFrame=false)`

4. `SetCollider(gameObject="Self", active=0, resetOnExit=false)`

5. `StopCrawler(Target="Self", WaitForTurn=0)`



### MossBone Crawler Summon / Summon Control [external_linked_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:476552>)

变量初值：`{"floatVariables":{"Death Speed":0,"Spawn X":0,"SpawnX 1":-8.6,"SpawnX 2":-8.6,"Kill Angle":0,"Offset":0,"Rotation":0,"Z Pos":0,"Spawn Y":0},"gameObjectVariables":{"Antic Dust":{"fileID":0},"Antic Rocks":{"fileID":0},"Mother":{"fileID":1593},"Self":{"fileID":0},"Hero":{"fileID":0},"Extract Point":{"fileID":0},"Audio Loop Voice":{"fileID":1873}}}`

全局迁移：`[{"fsmEvent":{"name":"EXTRACT","isSystemEvent":0,"isGlobal":0},"toState":"Extract","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0},{"fsmEvent":{"name":"ZERO HP","isSystemEvent":0,"isGlobal":0},"toState":"Corpse Away","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0},{"fsmEvent":{"name":"CRUSH","isSystemEvent":0,"isGlobal":0},"toState":"Crush Death","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0},{"fsmEvent":{"name":"BOSS BATTLE END","isSystemEvent":0,"isGlobal":0},"toState":"Corpse Away","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0}]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:476569>)

出口：FINISHED → Dormant。isSequence=0。

1. `FindChild(gameObject="Self", childName="Antic Dust", storeResult="$Antic Dust")`

2. `FindChild(gameObject="Self", childName="Antic Rocks", storeResult="$Antic Rocks")`

3. `GetOwner(storeGameObject="$Self")`

4. `GetHero(storeResult="$Hero")`

5. `GetPosition2D(gameObject="Self", vector="None", x="None", y="$Spawn Y", space=1, everyFrame=false)`

6. `EnableFSM(gameObject="Self", fsmName="Noise Reaction", enable=0, resetOnExit=0)`



#### Dormant · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:476764>)

出口：SPAWN → Spawn Pause。isSequence=0。

1. `SetPosition2d(gameObject="Self", vector="None", x=-100, y="None", space=0, everyFrame=false, lateUpdate=false)`



#### Position · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:476860>)

出口：FINISHED → Antic；BOSS KILL → Die。isSequence=0。

1. `RandomFloatEither(value1="$SpawnX 1", value2="$SpawnX 2", storeResult="$Spawn X")`

2. `SetPosition(gameObject="Self", vector="None", x="$Spawn X", y="$Spawn Y", z="None", space=1, everyFrame=false, lateUpdate=false)`

3. `SetHP(target="Self", hp=10)`



#### Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:477013>)

出口：NEXT → Fall；BOSS KILL → Die。isSequence=0。

1. `PlayParticleEmitterInState(gameObject="Owner($Antic Dust)")`

2. `PlayParticleEmitterInState(gameObject="Owner($Antic Rocks)")`

3. `Wait(time=0.75, finishEvent="NEXT", realTime=false)`

4. `AudioPlayerOneShot(audioPlayer="GUID:e8466d04a5c03bc4b8d6a0838af84de7#1709254077376921", spawnPoint="$Self", audioClips=["GUID:b47c68feccbc0c84b9562417f526f00e#8300000","GUID:95b9cb4101bbbd24c92ddca266151d34#8300000","GUID:a42edaf49998bc24bb2012762bff4f67#8300000"], weights=[1,1,1], pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Fall · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:477199>)

出口：LAND → Bounce；BOSS KILL → Corpse Away。isSequence=0。

1. `SetCollider(gameObject="Self", active=1, resetOnExit=false)`

2. `FaceObject(objectA="$Self", objectB="$Hero", spriteFacesRight=0, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false)`

3. `SetIsKinematic2d(gameObject="Self", isKinematic=0)`

4. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="SummonFall")`

5. `SetMeshRenderer(gameObject="Self", active=1)`

6. `CheckCollisionSideEnter(topHit="None", rightHit="None", bottomHit="None", leftHit="None", topHitEvent=null, rightHitEvent=null, bottomHitEvent="LAND", leftHitEvent=null, otherLayer=false, otherLayerNumber=0, ignoreTriggers=0)`

7. `CheckCollisionSide(collidingObject="Self", topHit="None", rightHit="None", bottomHit="None", leftHit="None", topHitEvent=null, rightHitEvent=null, bottomHitEvent="LAND", leftHitEvent=null, otherLayer=false, otherLayerNumber=0, ignoreTriggers=0)`



#### Land · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:477485>)

出口：FINISHED → Move；BOSS KILL → Corpse Away。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="SummonLand", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `FaceObject(objectA="$Self", objectB="$Hero", spriteFacesRight=0, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false)`



#### Move · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:477610>)

出口：BOSS KILL → Corpse Away。isSequence=0。

1. `EnableFSM(gameObject="Self", fsmName="Noise Reaction", enable=1, resetOnExit=1)`

2. `StartCrawler(Target="Self", ScheduleTurn=0)`

3. `AudioPlayInState(gameObject="Self", volume=1)`



#### Die · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:477739>)

出口：FINISHED → Dormant。isSequence=0。

1. `SetIsKinematic2d(gameObject="Self", isKinematic=1)`

2. `SetVelocity2d(gameObject="Self", vector={"x":0,"y":0}, x="None", y="None", everyFrame=false)`

3. `SetMeshRenderer(gameObject="Self", active=0)`



#### Corpse Away · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:477869>)

出口：FINISHED → Die。isSequence=0。

1. `EnemyDeathEffectsRegular+SimulateDeath(target="Self")`

2. `SetFsmBool(gameObject="Owner($Mother)", fsmName="Control", variableName="Spawned", setValue=0, everyFrame=false)`

3. `AudioPlayRandomVoiceFromTable(gameObject="Owner($Audio Loop Voice)", audioClipTable="GUID:c98e975e288d3034f95c45c8f5a2202c#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`

4. `FaceObject(objectA="$Self", objectB="$Hero", spriteFacesRight=0, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false)`

5. `SetCollider(gameObject="Self", active=0, resetOnExit=false)`

6. `StopCrawler(Target="Self", WaitForTurn=0)`

7. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Death Air")`

8. `GetScale(gameObject="Self", vector="None", xScale="$Death Speed", yScale="None", zScale="None", space=0, everyFrame=false)`

9. `FloatMultiply(floatVariable="$Death Speed", multiplyBy=5, everyFrame=false)`

10. `SetVelocity2d(gameObject="Self", vector="None", x="$Death Speed", y=20, everyFrame=false)`

11. `Wait(time=1, finishEvent="FINISHED", realTime=false)`

12. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($CameraParent)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="EnemyKillShake", delay=0, everyFrame=false)`

13. `SendMessage(gameObject="Owner($GameManager)", delivery=0, options=1, functionCall={"FunctionName":"FreezeMoment","parameterType":"int","BoolParameter":0,"FloatParameter":0,"IntParameter":1,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`



#### Bounce · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:478381>)

出口：FINISHED → BounceUp；BOSS KILL → Corpse Away。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="SummonBounce", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `AudioPlayRandomVoiceFromTable(gameObject="Owner($Audio Loop Voice)", audioClipTable="GUID:18fd8b755d8e99a44bb0ae3d1aaf0efa#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`

3. `AudioPlayerOneShot(audioPlayer="GUID:e8466d04a5c03bc4b8d6a0838af84de7#1709254077376921", spawnPoint="$Self", audioClips=["GUID:8df438dfd759e3d40af7d126886e748e#8300000","GUID:5838a93b99a327a4cae5a65a8dfcef21#8300000","GUID:edbab5cc3b71ce94faa79211ddc56b6e#8300000"], weights=[1,1,1], pitchMin=1.15, pitchMax=1.25, volume=1, delay=0, storePlayer="fileID:0")`



#### BounceUp · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:478577>)

出口：FINISHED → BounceFall；BOSS KILL → Corpse Away。isSequence=0。

1. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="SummonFall")`

2. `RandomFloat(min=9, max=12, storeResult="None")`

3. `SetVelocity2d(gameObject="Self", vector="None", x="None", y=9, everyFrame=false)`

4. `NextFrameEvent(sendEvent="FINISHED")`



#### BounceFall · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:478732>)

出口：BOSS KILL → Corpse Away；LAND → Land。isSequence=0。

1. `CheckCollisionSideEnter(topHit="None", rightHit="None", bottomHit="None", leftHit="None", topHitEvent=null, rightHitEvent=null, bottomHitEvent="LAND", leftHitEvent=null, otherLayer=false, otherLayerNumber=0, ignoreTriggers=0)`

2. `CheckCollisionSide(collidingObject="Self", topHit="None", rightHit="None", bottomHit="None", leftHit="None", topHitEvent=null, rightHitEvent=null, bottomHitEvent="LAND", leftHitEvent=null, otherLayer=false, otherLayerNumber=0, ignoreTriggers=0)`



#### Spawn Pause · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:478905>)

出口：FINISHED → Position。isSequence=0。

1. `WaitRandom(timeMin=0, timeMax=0.5, finishEvent="FINISHED", realTime=false)`



#### Extract · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:478985>)

出口：EXTRACT FINISH → Extract End。isSequence=0。

1. `EnemyDeathEffectsRegular+SimulateDeath(target="Self")`

2. `StopCrawler(Target="Self", WaitForTurn=0)`

3. `SetVelocity2d(gameObject="Self", vector={"x":0,"y":0}, x="None", y="None", everyFrame=false)`

4. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Extract")`

5. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=0, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

6. `SetCollider(gameObject="Self", active=0, resetOnExit=false)`

7. `SetIsKinematic2d(gameObject="Self", isKinematic=1)`

8. `GetScale(gameObject="Self", vector="None", xScale="$Rotation", yScale="None", zScale="None", space=0, everyFrame=false)`

9. `GetScale(gameObject="Self", vector="None", xScale="$Offset", yScale="None", zScale="None", space=0, everyFrame=false)`

10. `FloatMultiply(floatVariable="$Rotation", multiplyBy=-90, everyFrame=false)`

11. `FloatMultiply(floatVariable="$Offset", multiplyBy=0.25, everyFrame=false)`

12. `SetRotation(gameObject="Self", quaternion="None", vector="None", xAngle="None", yAngle="None", zAngle="$Rotation", space=0, everyFrame=false, lateUpdate=false)`

13. `FindChild(gameObject="Owner($Hero)", childName="Tool Effects/Extract Point", storeResult="$Extract Point")`

14. `GetPosition(gameObject="Self", vector="None", x="None", y="None", z="$Z Pos", space=0, everyFrame=false)`

15. `SetPositionToObject(gameObject="Self", targetObject="$Extract Point", xOffset="$Offset", yOffset=0, zOffset="None", overrideZ=0.003, everyFrame=false)`

16. `SendMessage(gameObject="Self", delivery=0, options=1, functionCall={"FunctionName":"FlashingMossExtract","parameterType":"None","BoolParameter":0,"FloatParameter":0,"IntParameter":0,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`



#### Extract End · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:479621>)

出口：FINISHED → Corpse Away。isSequence=0。

1. `SendMessage(gameObject="Self", delivery=0, options=1, functionCall={"FunctionName":"CancelFlash","parameterType":"None","BoolParameter":0,"FloatParameter":0,"IntParameter":0,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`

2. `SetIsKinematic2d(gameObject="Self", isKinematic=0)`



#### Crush Death · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:479837>)

出口：FINISHED → Die。isSequence=0。

1. `PlayAudioEvent(audioClip="GUID:d921724037ad76c429becd63cb4c9677#8300000", pitchMin=1, pitchMax=1, volume=1, audioPlayerPrefab="None", spawnPoint="Self", spawnPosition={"x":0,"y":0,"z":0}, SpawnedPlayerRef="None")`

2. `EnemyDeathEffectsRegular+SimulateDeath(target="Self")`

3. `SetFsmBool(gameObject="Owner($Mother)", fsmName="Control", variableName="Spawned", setValue=0, everyFrame=false)`

4. `SetCollider(gameObject="Self", active=0, resetOnExit=false)`

5. `StopCrawler(Target="Self", WaitForTurn=0)`



### MossBone Crawler Summon / Noise Reaction [external_linked_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:556825>)

变量初值：`{"floatVariables":{"Direction To Hero":0,"Scale X":0,"Z Pos":0,"Rotation":0,"Offset":0,"Kill Angle":0},"boolVariables":{"Facing Left":0,"Hero Is Right":0,"Should Turn":0,"Should Turn Left":0,"Should Turn Right":0},"gameObjectVariables":{"Hero":{"fileID":0},"Extract Point":{"fileID":0},"Audio Loop Voice":{"fileID":1873}},"enumVariables":{"Crawler Type":null}}`

全局迁移：`[{"fsmEvent":{"name":"EXTRACT","isSystemEvent":0,"isGlobal":0},"toState":"Extract","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0}]`

#### Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:556842>)

出口：WAKE → Type。isSequence=0。

1. `CheckHeroPerformanceRegion(Target="Self", MinReactDelay=0.1, MaxReactDelay=0.3, None=null, ActiveInner=null, ActiveOuter="WAKE", IgnoreNeedolinRange=0, useActiveBool=false, ActiveBool="None", StoreState="None", EveryFrame=true)`



#### Type · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:556958>)

出口：FINISHED → Wait；FLOOR → Wake Directional。isSequence=0。

1. `CallMethodProper(gameObject="Self", behaviour="Crawler", methodName="EndAmbientIdle", parameters=[], storeResult={"variableName":null,"objectType":"UnityEngine.Object","useVariable":1,"type":-1,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}, EveryFrame=false)`

2. `GetCrawlerType(StoreType="$Crawler Type", Target="Self")`

3. `EnumSwitch(enumVariable="$Crawler Type", compareTo=[0], sendEvent=["FLOOR"], everyFrame=false)`



#### Wake Directional · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:557125>)

出口：FINISHED → Wait。isSequence=0。

1. `StopCrawler(Target="Self", WaitForTurn=0)`

2. `GetDirection2D(From="Self", To="$Hero", StoreVector="None", StoreX="$Direction To Hero", StoreY="None", EveryFrame=false)`

3. `GetScale(gameObject="Self", vector="None", xScale="$Scale X", yScale="None", zScale="None", space=0, everyFrame=false)`

4. `FloatSignToBool(Value="$Direction To Hero", StoreIsPositive="$Hero Is Right", EveryFrame=false)`

5. `FloatSignToBool(Value="$Scale X", StoreIsPositive="$Facing Left", EveryFrame=false)`

6. `BoolTestMulti(boolVariables=["$Hero Is Right","$Facing Left"], boolStates=[1,1], trueEvent=null, falseEvent=null, storeResult="$Should Turn Right", everyFrame=false)`

7. `BoolTestMulti(boolVariables=["$Hero Is Right","$Facing Left"], boolStates=[0,0], trueEvent=null, falseEvent=null, storeResult="$Should Turn Left", everyFrame=false)`

8. `BoolAnyTrue(boolVariables=["$Should Turn Left","$Should Turn Right"], sendEvent=null, storeResult="$Should Turn", everyFrame=false)`

9. `StartCrawler(Target="Self", ScheduleTurn="$Should Turn")`



#### Wait · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:557457>)

出口：FINISHED → Idle；SING → Sing。isSequence=0。

1. `CheckHeroPerformanceRegion(Target="Self", MinReactDelay=0, MaxReactDelay=0, None="FINISHED", ActiveInner=null, ActiveOuter=null, IgnoreNeedolinRange=0, useActiveBool=false, ActiveBool="None", StoreState="None", EveryFrame=true)`

2. `CheckHeroPerformanceRegion(Target="Self", MinReactDelay=0.2, MaxReactDelay=0.4, None=null, ActiveInner="SING", ActiveOuter=null, IgnoreNeedolinRange=0, useActiveBool=false, ActiveBool="None", StoreState="None", EveryFrame=true)`



#### Sing · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:557637>)

出口：CANCEL → Sing End；SING DURATION END → Sing End。isSequence=0。

1. `CheckHeroPerformanceRegion(Target="Self", MinReactDelay=0.2, MaxReactDelay=0.4, None="CANCEL", ActiveInner=null, ActiveOuter=null, IgnoreNeedolinRange=0, useActiveBool=false, ActiveBool="None", StoreState="None", EveryFrame=true)`

2. `StopCrawler(Target="Self", WaitForTurn=0)`

3. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Sing", animationTriggerEvent=null, animationCompleteEvent=null)`

4. `EnemySingControl(enemyGameObject="Self", audioPlayer="$Audio Loop Voice", singAudioTable="GUID:4969863890bf96f46addb777a6743188#11400000", noThreadEffects=0, noPuppetString=0, randomSingStartTime=1, dontStopAudioOnExit=0, altThreadSpawnPoint="fileID:0")`



#### Sing End · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:557863>)

出口：FINISHED → Return Control。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Sing End", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`



#### Return Control · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:557946>)

出口：FINISHED → Idle。isSequence=0。

1. `StartCrawler(Target="Self", ScheduleTurn=0)`



#### Extract · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:558025>)

出口：EXTRACT FINISH → Kill Dir。isSequence=0。

1. `EnemyDeathEffectsRegular+SimulateDeath(target="Self")`

2. `StopCrawler(Target="Self", WaitForTurn=0)`

3. `SetVelocity2d(gameObject="Self", vector={"x":0,"y":0}, x="None", y="None", everyFrame=false)`

4. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Extract")`

5. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=0, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

6. `SetCollider(gameObject="Self", active=0, resetOnExit=false)`

7. `SetIsKinematic2d(gameObject="Self", isKinematic=1)`

8. `GetScale(gameObject="Self", vector="None", xScale="$Rotation", yScale="None", zScale="None", space=0, everyFrame=false)`

9. `GetScale(gameObject="Self", vector="None", xScale="$Offset", yScale="None", zScale="None", space=0, everyFrame=false)`

10. `FloatMultiply(floatVariable="$Rotation", multiplyBy=-90, everyFrame=false)`

11. `FloatMultiply(floatVariable="$Offset", multiplyBy=0.25, everyFrame=false)`

12. `SetRotation(gameObject="Self", quaternion="None", vector="None", xAngle="None", yAngle="None", zAngle="$Rotation", space=0, everyFrame=false, lateUpdate=false)`

13. `FindChild(gameObject="Owner($Hero)", childName="Tool Effects/Extract Point", storeResult="$Extract Point")`

14. `GetPosition(gameObject="Self", vector="None", x="None", y="None", z="$Z Pos", space=0, everyFrame=false)`

15. `SetPositionToObject(gameObject="Self", targetObject="$Extract Point", xOffset="$Offset", yOffset=0, zOffset="None", overrideZ=0.003, everyFrame=false)`

16. `SendMessage(gameObject="Self", delivery=0, options=1, functionCall={"FunctionName":"FlashingMossExtract","parameterType":"None","BoolParameter":0,"FloatParameter":0,"IntParameter":0,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`



#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:558661>)

出口：FINISHED → Idle。isSequence=0。

1. `GetHero(storeResult="$Hero")`



#### Extract Kill · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:558731>)

出口：无本地迁移（持续/外部驱动）。isSequence=0。

1. `InstaDeath(target="Self", direction="$Kill Angle")`



#### Kill Dir · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:558801>)

出口：FINISHED → Extract Kill。isSequence=0。

1. `SetFloatValue(floatVariable="$Kill Angle", floatValue=0, everyFrame=false)`

2. `SendEventByScale(gameObject="Self", eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, xScale=true, positiveEvent="FINISHED", negativeEvent=null, space=0)`

3. `SetFloatValue(floatVariable="$Kill Angle", floatValue=180, everyFrame=false)`



#### Floor Startle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:558946>)

出口：FINISHED → State 1。isSequence=0。

1. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Startle")`

2. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=true, newAnimationClip="TurnToStartle", resetFrame=true, everyFrame=false, pauseBetweenTurns=0.5)`

3. `Tk2dWatchAnimationEvents(gameObject="Self", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`



#### State 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:559083>)

出口：无本地迁移（持续/外部驱动）。isSequence=0。



### MossBone Crawler Summon (1) / Noise Reaction [external_linked_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:559328>)

变量初值：`{"floatVariables":{"Direction To Hero":0,"Scale X":0,"Z Pos":0,"Rotation":0,"Offset":0,"Kill Angle":0},"boolVariables":{"Facing Left":0,"Hero Is Right":0,"Should Turn":0,"Should Turn Left":0,"Should Turn Right":0},"gameObjectVariables":{"Hero":{"fileID":0},"Extract Point":{"fileID":0},"Audio Loop Voice":{"fileID":1872}},"enumVariables":{"Crawler Type":null}}`

全局迁移：`[{"fsmEvent":{"name":"EXTRACT","isSystemEvent":0,"isGlobal":0},"toState":"Extract","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0}]`

#### Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:559345>)

出口：WAKE → Type。isSequence=0。

1. `CheckHeroPerformanceRegion(Target="Self", MinReactDelay=0.1, MaxReactDelay=0.3, None=null, ActiveInner=null, ActiveOuter="WAKE", IgnoreNeedolinRange=0, useActiveBool=false, ActiveBool="None", StoreState="None", EveryFrame=true)`



#### Type · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:559461>)

出口：FINISHED → Wait；FLOOR → Wake Directional。isSequence=0。

1. `CallMethodProper(gameObject="Self", behaviour="Crawler", methodName="EndAmbientIdle", parameters=[], storeResult={"variableName":null,"objectType":"UnityEngine.Object","useVariable":1,"type":-1,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}, EveryFrame=false)`

2. `GetCrawlerType(StoreType="$Crawler Type", Target="Self")`

3. `EnumSwitch(enumVariable="$Crawler Type", compareTo=[0], sendEvent=["FLOOR"], everyFrame=false)`



#### Wake Directional · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:559628>)

出口：FINISHED → Wait。isSequence=0。

1. `StopCrawler(Target="Self", WaitForTurn=0)`

2. `GetDirection2D(From="Self", To="$Hero", StoreVector="None", StoreX="$Direction To Hero", StoreY="None", EveryFrame=false)`

3. `GetScale(gameObject="Self", vector="None", xScale="$Scale X", yScale="None", zScale="None", space=0, everyFrame=false)`

4. `FloatSignToBool(Value="$Direction To Hero", StoreIsPositive="$Hero Is Right", EveryFrame=false)`

5. `FloatSignToBool(Value="$Scale X", StoreIsPositive="$Facing Left", EveryFrame=false)`

6. `BoolTestMulti(boolVariables=["$Hero Is Right","$Facing Left"], boolStates=[1,1], trueEvent=null, falseEvent=null, storeResult="$Should Turn Right", everyFrame=false)`

7. `BoolTestMulti(boolVariables=["$Hero Is Right","$Facing Left"], boolStates=[0,0], trueEvent=null, falseEvent=null, storeResult="$Should Turn Left", everyFrame=false)`

8. `BoolAnyTrue(boolVariables=["$Should Turn Left","$Should Turn Right"], sendEvent=null, storeResult="$Should Turn", everyFrame=false)`

9. `StartCrawler(Target="Self", ScheduleTurn="$Should Turn")`



#### Wait · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:559960>)

出口：FINISHED → Idle；SING → Sing。isSequence=0。

1. `CheckHeroPerformanceRegion(Target="Self", MinReactDelay=0, MaxReactDelay=0, None="FINISHED", ActiveInner=null, ActiveOuter=null, IgnoreNeedolinRange=0, useActiveBool=false, ActiveBool="None", StoreState="None", EveryFrame=true)`

2. `CheckHeroPerformanceRegion(Target="Self", MinReactDelay=0.2, MaxReactDelay=0.4, None=null, ActiveInner="SING", ActiveOuter=null, IgnoreNeedolinRange=0, useActiveBool=false, ActiveBool="None", StoreState="None", EveryFrame=true)`



#### Sing · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:560140>)

出口：CANCEL → Sing End；SING DURATION END → Sing End。isSequence=0。

1. `CheckHeroPerformanceRegion(Target="Self", MinReactDelay=0.2, MaxReactDelay=0.4, None="CANCEL", ActiveInner=null, ActiveOuter=null, IgnoreNeedolinRange=0, useActiveBool=false, ActiveBool="None", StoreState="None", EveryFrame=true)`

2. `StopCrawler(Target="Self", WaitForTurn=0)`

3. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Sing", animationTriggerEvent=null, animationCompleteEvent=null)`

4. `EnemySingControl(enemyGameObject="Self", audioPlayer="$Audio Loop Voice", singAudioTable="GUID:4969863890bf96f46addb777a6743188#11400000", noThreadEffects=0, noPuppetString=0, randomSingStartTime=1, dontStopAudioOnExit=0, altThreadSpawnPoint="fileID:0")`



#### Sing End · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:560366>)

出口：FINISHED → Return Control。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Sing End", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`



#### Return Control · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:560449>)

出口：FINISHED → Idle。isSequence=0。

1. `StartCrawler(Target="Self", ScheduleTurn=0)`



#### Extract · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:560528>)

出口：EXTRACT FINISH → Kill Dir。isSequence=0。

1. `EnemyDeathEffectsRegular+SimulateDeath(target="Self")`

2. `StopCrawler(Target="Self", WaitForTurn=0)`

3. `SetVelocity2d(gameObject="Self", vector={"x":0,"y":0}, x="None", y="None", everyFrame=false)`

4. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Extract")`

5. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=0, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

6. `SetCollider(gameObject="Self", active=0, resetOnExit=false)`

7. `SetIsKinematic2d(gameObject="Self", isKinematic=1)`

8. `GetScale(gameObject="Self", vector="None", xScale="$Rotation", yScale="None", zScale="None", space=0, everyFrame=false)`

9. `GetScale(gameObject="Self", vector="None", xScale="$Offset", yScale="None", zScale="None", space=0, everyFrame=false)`

10. `FloatMultiply(floatVariable="$Rotation", multiplyBy=-90, everyFrame=false)`

11. `FloatMultiply(floatVariable="$Offset", multiplyBy=0.25, everyFrame=false)`

12. `SetRotation(gameObject="Self", quaternion="None", vector="None", xAngle="None", yAngle="None", zAngle="$Rotation", space=0, everyFrame=false, lateUpdate=false)`

13. `FindChild(gameObject="Owner($Hero)", childName="Tool Effects/Extract Point", storeResult="$Extract Point")`

14. `GetPosition(gameObject="Self", vector="None", x="None", y="None", z="$Z Pos", space=0, everyFrame=false)`

15. `SetPositionToObject(gameObject="Self", targetObject="$Extract Point", xOffset="$Offset", yOffset=0, zOffset="None", overrideZ=0.003, everyFrame=false)`

16. `SendMessage(gameObject="Self", delivery=0, options=1, functionCall={"FunctionName":"FlashingMossExtract","parameterType":"None","BoolParameter":0,"FloatParameter":0,"IntParameter":0,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`



#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:561164>)

出口：FINISHED → Idle。isSequence=0。

1. `GetHero(storeResult="$Hero")`



#### Extract Kill · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:561234>)

出口：无本地迁移（持续/外部驱动）。isSequence=0。

1. `InstaDeath(target="Self", direction="$Kill Angle")`



#### Kill Dir · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:561304>)

出口：FINISHED → Extract Kill。isSequence=0。

1. `SetFloatValue(floatVariable="$Kill Angle", floatValue=0, everyFrame=false)`

2. `SendEventByScale(gameObject="Self", eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, xScale=true, positiveEvent="FINISHED", negativeEvent=null, space=0)`

3. `SetFloatValue(floatVariable="$Kill Angle", floatValue=180, everyFrame=false)`



#### Floor Startle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:561449>)

出口：FINISHED → State 1。isSequence=0。

1. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Startle")`

2. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=true, newAnimationClip="TurnToStartle", resetFrame=true, everyFrame=false, pauseBetweenTurns=0.5)`

3. `Tk2dWatchAnimationEvents(gameObject="Self", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`



#### State 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:561586>)

出口：无本地迁移（持续/外部驱动）。isSequence=0。



### 动画事件索引

[动画库](</Users/mars/workspace/SilksongUnity6/Assets/Animations/Bosses/Mossbone Mother Anim.prefab:1>)

|Clip|帧数|fps|wrapMode|loopStart|触发索引0基/标称秒|
|---|---:|---:|---:|---:|---|

|Antic|3|15|0|0||

|Fly|4|12|0|0||

|Charge|3|15|0|1||

|Charge Recover|8|12|1|4||

|Roar|3|15|0|0||

|FlyUp|2|15|0|0||

|Smash|6|12|2|0||

|TurnToFly|6|12|1|2||

|RoofAntic|5|12.5|2|0||

|Gate Closed|1|30|0|0||

|Gate Close|5|15|2|0||

|Gate Open|4|15|2|0||

|Stun|5|12|1|2||

|Recover|3|15|2|0||

|Stun Hit|4|12|1|1||

|Gate Hit|5|18|2|0||


### 物理、伤害与碰撞组件定位

#### Mossbone Mother [组件3963](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:67165>)

```yaml
Rigidbody2D:
  serializedVersion: 5
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1593}
  m_BodyType: 0
  m_Simulated: 1
  m_UseFullKinematicContacts: 0
  m_UseAutoMass: 0
  m_Mass: 1
  m_LinearDamping: 0
  m_AngularDamping: 0.05
  m_GravityScale: 0
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_Interpolate: 0
  m_SleepingMode: 0
  m_CollisionDetection: 1
  m_Constraints: 4
```

#### Cocoon [组件4005](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:68855>)

```yaml
PolygonCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1318}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0.5, y: 0.5}
    oldSize: {x: 3.640625, y: 4.671875}
    newSize: {x: 2.859375, y: 3.671875}
    adaptiveTilingThreshold: 0.5
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Points:
    m_Paths:
    - - {x: 0.020972133, y: -1.6405923}
      - {x: -0.75446427, y: -1.1516302}
      - {x: -1.2626506, y: -0.26714683}
      - {x: -1.1248561, y: 1.0386641}
      - {x: -0.076195836, y: 1.7938025}
      - {x: 0.8052319, y: 1.2970355}
      - {x: 1.2771443, y: 0.32129312}
      - {x: 0.94360626, y: -1.0269182}
  m_UseDelaunayMesh: 0
```

#### Terrain Block [组件4058](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:71384>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1298}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 0
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: -0.26958466, y: -0.5208435}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 2.2662735, y: 1.8991585}
  m_EdgeRadius: 0
```

#### Mossbone Mother [组件4107](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:73638>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1593}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 0
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0.025979996, y: 0.025453568}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 1.4283638, y: 2.8674126}
  m_EdgeRadius: 0
```

#### Wake Range [组件4108](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:73684>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 732}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: -1.173336, y: 9.4098215}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 7.078453, y: 17.020163}
  m_EdgeRadius: 0
```

#### Mossbone Mother [组件6212](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:491517>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1593}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 7e0b9799fb0157646caefd91bc67f0a6, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  audioPlayerPrefab: {fileID: 82724804207875695, guid: 99068b2a95bddff419cb6f176648d4e6, type: 2}
  regularInvincibleAudio:
    Clip: {fileID: 0}
    PitchMin: 0.75
    PitchMax: 1.25
    Volume: 1
    vibrationDataAsset: {fileID: 0}
  blockHitPrefab: {fileID: 1709254077376921, guid: e3986d204468fc44ebaf84af5df3fdfa, type: 2}
  strikeNailPrefab: {fileID: 1709254077376921, guid: 64c20baf394ac9a41b03deea82568445, type: 2}
  slashImpactPrefab: {fileID: 1709254077376921, guid: 97c9ba031f06bae4681d3fda13c3f87b, type: 2}
  corpseSplatPrefab: {fileID: 1709254077376921, guid: ee26d04f9efdaa7458f4fcea07e485df, type: 2}
  hp: 120
  damageScaling:
    Level1Mult: 1
    Level2Mult: 1
    Level3Mult: 1
    Level4Mult: 1
    Level5Mult: 1
  enemyType: 0
  doNotGiveSilk: 0
  ignoreFlags: 0
  reaperBundles: 0
  effectOrigin: {x: 0, y: -0.2, z: 0}
  ignoreKillAll: 0
  sendDamageTo: {fileID: 0}
  isPartOfSendToTarget: 0
  tagDamageTakerIgnoreColliderState: 0
  takeTagDamageWhileInvincible: 0
  targetPointOverride: {fileID: 0}
  battleScene: {fileID: 0}
  sendHitTo: {fileID: 0}
  sendKilledToObject: {fileID: 0}
  sendKilledToName:
  smallGeoDrops: 0
  mediumGeoDrops: 0
  largeGeoDrops: 0
  largeSmoothGeoDrops: 0
  megaFlingGeo: 0
  shellShardDrops: 0
  flingSilkOrbsDown: 0
  flingSilkOrbsAimObject: {fileID: 0}
  itemDropGroups: []
  _itemDropProbability: 0
  _itemDrops: []
  hasAlternateHitAnimation: 0
  alternateHitAnimation: False
  invincible: 1
  piercable: 0
  invincibleFromDirection: 0
  preventInvincibleEffect: 0
  preventInvincibleShake: 0
  preventInvincibleAttackBlock: 0
  invincibleRecoil: 0
  dontSendTinkToDamager: 0
  hasAlternateInvincibleSound: 0
  alternateInvincibleSound: {fileID: 8300000, guid: 0479d63254f701140b49cded3764295c, type: 3}
  immuneToNailAttacks: 0
  immuneToExplosions: 0
  immuneToBeams: 0
  immuneToHunterWeapon: 0
  immuneToCoal: 0
  immuneToTraps: 0
  immuneToWater: 0
  immuneToSpikes: 0
  immuneToLava: 0
  isMossExtractable: 1
  isSwampExtractable: 0
  isBluebloodExtractable: 0
  deathAudioSnapshot: {fileID: 0}
  hasSpecialDeath: 0
  deathReset: 0
  damageOverride: 0
  ignoreAcid: 0
  ignoreWater: 0
  zeroHPEventOverride: {fileID: 0}
  dontDropMeat: 0
  enemySize: 1
  bigEnemyDeath: 0
  preventDeathAfterHero: 1
  ignoreHazards: 0
  invulnerableTime: 0.25
  semiPersistent: 0
  isDead: 0
  ignorePersistence: 0
  tinkTimer: 0
```

#### Mossbone Mother [组件6527](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:565798>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1593}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 49c386a20fdaa83a59c1a091a909e14c, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  damageDealt: 1
  hazardType: 1
  damageAsset: {fileID: 0}
  damagePropertyFlags: 0
  resetOnEnable: 0
  canClashTink: 0
  forceParry: 0
  noClashFreeze: 0
  noTerrainThunk: 0
  noTerrainRecoil: 0
  noCorpseSpikeStick: 0
  noBounceCooldown: 0
  overrideCollisionSide: 0
  collisionSide: 0
  invertCollisionSide: 0
  HeroDamagedFSM: {fileID: 0}
  AlwaysSendDamaged: 0
  HeroDamagedFSMEvent:
  HeroDamagedFSMBool:
  HeroDamagedFSMGameObject:
  ClashEvents:
    OnClashUp:
      m_PersistentCalls:
        m_Calls: []
    OnClashDown:
      m_PersistentCalls:
        m_Calls: []
    OnClashLeft:
      m_PersistentCalls:
        m_Calls: []
    OnClashRight:
      m_PersistentCalls:
        m_Calls: []
  OnDamagedHero:
    m_PersistentCalls:
      m_Calls: []
```

## Lace Boss1

### MultiHit / Multihitter [fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:405155>)

变量初值：`{"boolVariables":{"Bind Bell Hit":0,"Parrying":0},"gameObjectVariables":{"Lace":{"fileID":0}}}`

全局迁移：`[{"fsmEvent":{"name":"PARRIED","isSystemEvent":0,"isGlobal":0},"toState":"Parried Recover","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0}]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:405172>)

出口：FINISHED → Idle。isSequence=0。

1. `GetParent(gameObject="Self", storeResult="$Lace")`



#### Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:405251>)

出口：TRIGGER → Start Hit?。isSequence=0。

1. `Trigger2dEventLayer(trigger=1, collideTag="None", collideLayer=20, sendEvent="TRIGGER", storeCollider="None")`



#### Start Hit? · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:405338>)

出口：CANCEL → Idle；HIT → Hit。isSequence=0。

1. `CanHeroTakeDamage(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, canTakeDmgEvent="HIT", cannotTakeDmgEvent="CANCEL")`



#### Hit · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:405447>)

出口：MULTIHIT END → Idle；BIND BELL → Bind Bell Damage；CROSS STITCH → Cross Stitch。isSequence=0。

1. `GetHeroCState(VariableName="parrying", StoreValue="$Parrying", EveryFrame=false)`

2. `BoolTest(boolVariable="$Parrying", isTrue="CROSS STITCH", isFalse=null, everyFrame=false)`

3. `CallMethodProper(gameObject="Owner($Hero)", behaviour="HeroController", methodName="WillDoBellBindHit", parameters=[], storeResult={"variableName":"Bind Bell Hit","objectType":"UnityEngine.Object","useVariable":1,"type":2,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}, EveryFrame=false)`

4. `BoolTest(boolVariable="$Bind Bell Hit", isTrue="BIND BELL", isFalse=null, everyFrame=false)`

5. `CallMethodProper(gameObject="Owner($Hero)", behaviour="HeroController", methodName="TakeQuickDamage", parameters=[{"variableName":null,"objectType":null,"useVariable":0,"type":1,"floatValue":0,"intValue":1,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}},{"variableName":null,"objectType":null,"useVariable":0,"type":2,"floatValue":0,"intValue":0,"boolValue":1,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}], storeResult={"variableName":null,"objectType":null,"useVariable":1,"type":-1,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}, EveryFrame=false)`

6. `SendEventToRegister(eventName="HERO DAMAGED")`

7. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Hero)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="WOUND START", delay=0, everyFrame=false)`

8. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Lace)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="MULTI HIT CONNECT", delay=0, everyFrame=false)`

9. `Wait(time=2, finishEvent="MULTIHIT END", realTime=false)`



#### Bind Bell Damage · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:405848>)

出口：FINISHED → Idle。isSequence=0。

1. `DamageHeroDirectly(damager="Self", damageAmount=1, spikeHazard=false, sinkHazard=false)`



#### Cross Stitch · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:405929>)

出口：FINISHED → Idle。isSequence=0。

1. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Hero)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="PARRIED", delay=0, everyFrame=false)`

2. `Wait(time=0.5, finishEvent=null, realTime=false)`



#### Parried Recover · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:406052>)

出口：FINISHED → Idle。isSequence=0。

1. `Wait(time=0.3, finishEvent="FINISHED", realTime=false)`



### Lace Boss1 / Control [fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:406635>)

变量初值：`{"floatVariables":{"Centre X":93.78,"Counter Pause":0,"Distance":0,"Gravity":2,"Hero Y":0,"Land Y":7.598696,"Self X":0,"Stun Timer":0,"Target Distance":0,"X Scale":0,"Lava Pos Y":0,"Velocity Y":0},"intVariables":{"Ct Charge":0,"Ct Combo":0,"Ct CrossSlash":0,"Ct Evade":0,"Ct J Slash":0,"Evade Attempts":0,"Hops":0,"Invincibility Direction":0,"Ms Charge":0,"Ms Combo":0,"Ms Evade":0,"Ms J Slash":0,"Rage HP":0},"boolVariables":{"Counter Range":0,"Counter Ready":0,"CrossSlashing Hero":0,"Do Pose":0,"Facing Right":0,"Hero Is Right":0,"Hornet Dead":0,"Lace Is Right":0,"Needolin Fight":0,"Right Side":0,"Will Counter":0,"Will CrossSlash":0,"Bind Bell Hit":0,"NPC Blocked Hit":0,"Dormant Block":0,"Above Wallcling Min":0,"Not Above Hero":0,"Wall Ahead":0,"Below Ground":0},"stringVariables":{"Next Event":null},"vector3Variables":{"CS Lace Pos":{"x":0,"y":0,"z":0},"Multihit Pos":{"x":0,"y":0,"z":0}},"gameObjectVariables":{"AirDash Burst":{"fileID":1509},"Audio Player":{"fileID":0},"Battle Gates":{"fileID":0},"Battle Scene":{"fileID":0},"Boss Scene":{"fileID":0},"CS Exit Point":{"fileID":1458},"CS Hornet":{"fileID":0},"CS Slam Point":{"fileID":1551},"Charge Hit":{"fileID":1548},"Circle Slash 1":{"fileID":1588},"Circle Slash 2":{"fileID":1624},"Combo Slash 1":{"fileID":1760},"Combo Slash 2":{"fileID":1362},"Counter Flash":{"fileID":1412},"CrossSlash Energy":{"fileID":1413},"CrossSlash Obj":{"fileID":1783},"Dash Burst":{"fileID":1728},"DazedEffect Marker":{"fileID":0},"Downstab Hit":{"fileID":1582},"Eye Flash":{"fileID":1449},"MultiHit":{"fileID":1683},"Multihit Point":{"fileID":0},"Parry Clash Effect":{"fileID":1780},"Pt DashDust":{"fileID":1714},"Pt RapidSlash":{"fileID":1578},"Pt RisingDust1":{"fileID":1489},"Pt RisingDust2":{"fileID":1353},"Pt SkidDust":{"fileID":1460},"RapidSlash Effect":{"fileID":1646},"Self":{"fileID":0},"Silkflies":{"fileID":0},"Slam Effect":{"fileID":1677},"Slam Particles":{"fileID":0},"Thwip Slash":{"fileID":0},"Attack Detector":{"fileID":1836},"Effect":{"fileID":0},"CS Lace Sprite":{"fileID":1583},"CS Sprite Follower":{"fileID":1911},"Leap Burst":{"fileID":1909},"Pt Dust":{"fileID":1854},"Arena Centre":{"fileID":0},"Ray Pt":{"fileID":1881},"Wall Range Obj":{"fileID":0},"Audio Loop Voice":{"fileID":1852}},"objectVariables":{"Fight Range":{"fileID":0},"Wall Range":{"fileID":0}}}`

全局迁移：`[{"fsmEvent":{"name":"STUN","isSystemEvent":0,"isGlobal":0},"toState":"Stun Start","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0},{"fsmEvent":{"name":"LAVA DAMAGE","isSystemEvent":0,"isGlobal":0},"toState":"Lava Damage","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0}]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:406652>)

出口：FINISHED → Use Wall Range?。isSequence=0。

1. `GetOwner(storeGameObject="$Self")`

2. `GetHP(target="Self", storeValue="$Rage HP")`

3. `MultiplyIntByFloat(integer="$Rage HP", multiplyFloat=0.5, storeResult="$Rage HP", everyFrame=false, forceRoundUp=false)`

4. `FindChild(gameObject="Self", childName="MultiHit/Draw Point", storeResult="$Multihit Point")`

5. `FindChild(gameObject="Self", childName="Cross Slash/Hornet", storeResult="$CS Hornet")`

6. `FindChild(gameObject="Self", childName="AirDash Burst", storeResult="$AirDash Burst")`

7. `FindChild(gameObject="Self", childName="Charge Hit", storeResult="$Charge Hit")`

8. `FindChild(gameObject="Self", childName="Circle Slash 1", storeResult="$Circle Slash 1")`

9. `FindChild(gameObject="Self", childName="Circle Slash 2", storeResult="$Circle Slash 2")`

10. `FindChild(gameObject="Self", childName="Thwip Slash", storeResult="$Thwip Slash")`

11. `FindChild(gameObject="Self", childName="Combo Slash 1", storeResult="$Combo Slash 1")`

12. `FindChild(gameObject="Self", childName="Combo Slash 2", storeResult="$Combo Slash 2")`

13. `FindChild(gameObject="Self", childName="Counter Flash", storeResult="$Counter Flash")`

14. `FindChild(gameObject="Self", childName="CrossSlash Energy", storeResult="$CrossSlash Energy")`

15. `FindChild(gameObject="Self", childName="Cross Slash", storeResult="$CrossSlash Obj")`

16. `FindChild(gameObject="Self", childName="Dash Burst", storeResult="$Dash Burst")`

17. `FindChild(gameObject="Self", childName="Downstab Hit", storeResult="$Downstab Hit")`

18. `FindChild(gameObject="Self", childName="Eye Flash", storeResult="$Eye Flash")`

19. `FindChild(gameObject="Self", childName="MultiHit", storeResult="$MultiHit")`

20. `FindChild(gameObject="Self", childName="Parry Clash Effect", storeResult="$Parry Clash Effect")`

21. `FindChild(gameObject="Self", childName="Pt DashDust", storeResult="$Pt DashDust")`

22. `FindChild(gameObject="Self", childName="Pt RapidSlash", storeResult="$Pt RapidSlash")`

23. `FindChild(gameObject="Self", childName="Pt RisingDust1", storeResult="$Pt RisingDust1")`

24. `FindChild(gameObject="Self", childName="Pt RisingDust2", storeResult="$Pt RisingDust2")`

25. `FindChild(gameObject="Self", childName="Pt SkidDust", storeResult="$Pt SkidDust")`

26. `FindChild(gameObject="Self", childName="RapidSlash Effect", storeResult="$RapidSlash Effect")`

27. `FindChild(gameObject="Self", childName="Slam Effect", storeResult="$Slam Effect")`

28. `GetParent(gameObject="Self", storeResult="$Boss Scene")`

29. `FindChild(gameObject="Owner($Boss Scene)", childName="Battle Scene", storeResult="$Battle Scene")`

30. `FindChild(gameObject="Owner($Boss Scene)", childName="Battle Gates", storeResult="$Battle Gates")`

31. `FindChild(gameObject="Owner($Boss Scene)", childName="Silkflies", storeResult="$Silkflies")`

32. `FindChild(gameObject="Owner($Boss Scene)", childName="Slam Particles", storeResult="$Slam Particles")`

33. `FindAlertRange(target="Owner($Boss Scene)", storeResult="$Wall Range", childName="Wall Range")`

34. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Arena Centre")`



#### Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:407522>)

出口：ATTACK → CrossSlash?；TOOK DAMAGE → CrossSlash?；COUNTER → Counter Antic；RANGE OUT → Evade 2；SING → Sing Antic。isSequence=0。

1. `Wait(time=0.75, finishEvent="ATTACK", realTime=false)`

2. `FaceObjectV4(ObjectA="Self", ObjectB="$Hero", SpriteFacesRight=1, NewAnimationClip="TurnToIdle", ResetFrame=true, PauseBetweenTurns=0.25, StoreDuration="None", turnAudioClipTable="GUID:7e4a21cd4cc147c4084b1a0bc7f1a1bd#11400000", EveryFrame=false)`

3. `GetDistance(gameObject="Self", target="$Hero", storeResult="$Distance", everyFrame=true)`

4. `EaseFloat(fromValue=0, toValue=1, floatVariable="$Counter Pause", time=1, speed="None", delay="None", easeType=21, reverse=0, finishEvent=null, realTime=false)`

5. `FloatTestToBool(float1="$Distance", float2=6, tolerance=0, equalBool="None", lessThanBool="$Counter Range", greaterThanBool="None", everyFrame=true)`

6. `FloatTestToBool(float1="$Counter Pause", float2=0.25, tolerance=0, equalBool="None", lessThanBool="None", greaterThanBool="$Counter Ready", everyFrame=true)`

7. `BoolAllTrue(boolVariables=["$Counter Range","$Will Counter","$Counter Ready"], sendEvent="COUNTER", storeResult="None", everyFrame=true)`

8. `CheckAlertRange(alertRange="$Fight Range", storeResult="None", InRangeEvent=null, InRangeDelay=0, OutOfRangeEvent="RANGE OUT", OutOfRangeDelay=0, everyFrame=true)`

9. `CheckHeroPerformanceRegionV2(Target="Self", Radius=0, MinReactDelay=0.2, MaxReactDelay=0.2, None=null, ActiveInner="SING", ActiveOuter=null, IgnoreNeedolinRange=1, UseActiveBool=0, ActiveBool="None", StoreState="None", EveryFrame=true)`

10. `Tk2dWatchAnimationEvents(gameObject="Self", animationTriggerEvent=null, animationCompleteEvent="ATTACK")`



#### Charge Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:408000>)

出口：NEXT → Charge Break。isSequence=0。

1. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.0)`

2. `SetVelocityByScale(gameObject="Self", speed=-32, ySpeed="None", everyFrame=false)`

3. `DecelerateXY(gameObject="Self", decelerationX=0.825, decelerationY="None", brakeOnExit=true)`

4. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Charge Antic")`

5. `Wait(time=0.2, finishEvent="NEXT", realTime=false)`

6. `AudioPlayerOneShot(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClips=["GUID:5612842bd9c91d54ca36821974b6eeb9#8300000","GUID:9156961f29e23534aaf1cb3053337526#8300000","GUID:6d0241d0624997e48ad3c91b42bcb3d8#8300000","GUID:0a03f8b9434c4a9469fe976a81948350#8300000"], weights=[1,1,1,1], pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

7. `AudioPlayRandom(gameObject="$Self", audioClips=["GUID:fc6754484ac77164fa7c7677836ed985#8300000","GUID:09d74354307c2e845a247f377de81f40#8300000","GUID:7342cd20c228d3b4d895cb9f91e4bfd2#8300000","GUID:797c8d3bcc7af3e45bfda47c257c342c#8300000"], weights=[1,1,1,1], pitchMin=1, pitchMax=1)`



#### Charge · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:408340>)

出口：NEXT → Charge Recover。isSequence=0。

1. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Charge")`

2. `SetVelocityByScale(gameObject="Self", speed=80, ySpeed="None", everyFrame=false)`

3. `Wait(time=0.3, finishEvent="NEXT", realTime=false)`

4. `ActivateGameObject(gameObject="Owner($Charge Hit)", activate=1, recursive=0, resetOnExit=true, everyFrame=false)`

5. `ActivateGameObject(gameObject="Owner($Dash Burst)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

6. `DecelerateXY(gameObject="Self", decelerationX=0.89, decelerationY="None", brakeOnExit=false)`

7. `SetParticleEmission(gameObject="Owner($Pt DashDust)", emission=1, resetOnExit=true)`

8. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:a7288e0cec4770c48a39476458eb5cfc#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="$Audio Player")`

9. `PlayParticleEmitterInState(gameObject="Owner($Pt Dust)")`



#### Charge Recover · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:408633>)

出口：FINISHED → Will Counter?。isSequence=0。

1. `SetBoolValue(boolVariable="$Do Pose", boolValue=1, everyFrame=false)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Charge Recover", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `DecelerateXY(gameObject="Self", decelerationX=0.875, decelerationY="None", brakeOnExit=true)`



#### J Slash Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:408759>)

出口：NEXT → J Slash 1。isSequence=0。

1. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Jump Antic")`

3. `Wait(time=0.65, finishEvent="NEXT", realTime=false)`

4. `AudioPlayRandom(gameObject="$Self", audioClips=["GUID:290ad397e1c4a814abe4a4c3108fa10a#8300000","GUID:2e854a848e1a7de4b9d4aa14c2657d5e#8300000","GUID:797c8d3bcc7af3e45bfda47c257c342c#8300000","GUID:46f68756a14c92340bd5d57d42b1e703#8300000"], weights=[1,1,1,1], pitchMin=1, pitchMax=1)`



#### J Slash 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:408956>)

出口：FINISHED → J Slash 2。isSequence=0。

1. `SendMessage(gameObject="Self", delivery=0, options=0, functionCall={"FunctionName":"EndConstrain","parameterType":"None","BoolParameter":0,"FloatParameter":0,"IntParameter":0,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Rising Slash", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`

3. `SetGravity2dScale(gameObject="Self", gravityScale=0)`

4. `SetVelocityByScale(gameObject="Self", speed=60, ySpeed=87, everyFrame=false)`

5. `DecelerateV2(gameObject="Self", deceleration=0.825, brakeOnExit=false)`

6. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:5160a08e3a448c24d88d63010184c3cb#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

7. `ActivateGameObject(gameObject="Owner($Leap Burst)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`



#### Downstab Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:409325>)

出口：FINISHED → Downstab。isSequence=0。

1. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

2. `DecelerateV2(gameObject="Self", deceleration=0.825, brakeOnExit=false)`

3. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Downstab Antic", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`



#### J Slash 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:409463>)

出口：FINISHED → J Slash 3。isSequence=0。

1. `Tk2dWatchAnimationEvents(gameObject="Self", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`

2. `ActivateGameObject(gameObject="Owner($Circle Slash 1)", activate=1, recursive=0, resetOnExit=true, everyFrame=false)`

3. `DecelerateV2(gameObject="Self", deceleration=0.825, brakeOnExit=false)`



#### J Slash 3 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:409585>)

出口：FINISHED → J Slash 4。isSequence=0。

1. `Tk2dWatchAnimationEvents(gameObject="Self", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`

2. `ActivateGameObject(gameObject="Owner($Circle Slash 2)", activate=1, recursive=0, resetOnExit=true, everyFrame=false)`

3. `DecelerateV2(gameObject="Self", deceleration=0.825, brakeOnExit=false)`



#### J Slash 4 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:409707>)

出口：FINISHED → Dstab Constrain?。isSequence=0。

1. `Tk2dWatchAnimationEvents(gameObject="Self", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `DecelerateV2(gameObject="Self", deceleration=0.825, brakeOnExit=false)`



#### Downstab · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:409802>)

出口：LAND → Downstab Land；WALL → Wallcling。isSequence=0。

1. `ActivateGameObject(gameObject="Owner($Downstab Hit)", activate=1, recursive=0, resetOnExit=true, everyFrame=false)`

2. `AudioPlayRandom(gameObject="$Self", audioClips=["GUID:4d52a8fbdf1758c4fa274b3273d9bb02#8300000","GUID:7342cd20c228d3b4d895cb9f91e4bfd2#8300000"], weights=[1,1], pitchMin=1, pitchMax=1)`

3. `ActivateGameObject(gameObject="Owner($AirDash Burst)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

4. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Downstab")`

5. `SetVelocityByScale(gameObject="Self", speed=45, ySpeed=-45, everyFrame=false)`

6. `CheckIsCharacterGrounded(Target="Self", RayCount=3, GroundDistance=0.2, SkinWidth=-0.05, SkinHeight=0.1, StoreResult="None", GroundedEvent="LAND", NotGroundedEvent=null, EveryFrame=true)`

7. `CheckCollisionSideEnter(topHit="None", rightHit="None", bottomHit="None", leftHit="None", topHitEvent=null, rightHitEvent=null, bottomHitEvent="LAND", leftHitEvent=null, otherLayer=false, otherLayerNumber=0, ignoreTriggers=0)`

8. `GetVelocity2d(gameObject="Self", vector="None", x="None", y="$Velocity Y", space=0, everyFrame=true)`

9. `FloatCompare(float1="$Velocity Y", float2=-0.1, tolerance=0, equal=null, lessThan=null, greaterThan="LAND", everyFrame=true)`

10. `Wait(time=1, finishEvent="LAND", realTime=false)`

11. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:66b925fe8ad57604f8c467d9b8d5395a#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

12. `RayCast2dV2(fromGameObject="Owner($Ray Pt)", fromPosition="None", direction={"x":1,"y":0}, space=1, distance=1, minDepth="None", maxDepth="None", hitEvent=null, noHitEvent=null, storeDidHit="$Wall Ahead", storeHitObject="None", storeHitPoint="None", storeHitNormal="None", storeHitDistance="None", storeDistance="None", repeatInterval=1, layerMask=[8,15], invertMask=0, ignoreTriggers=0, debugColor={"r":1,"g":0.92156863,"b":0.015686275,"a":1}, debug=0)`

13. `CheckTargetDirection(gameObject="Self", target="$Hero", aboveEvent=null, belowEvent=null, rightEvent=null, leftEvent=null, aboveBool="$Not Above Hero", belowBool="None", rightBool="None", leftBool="None", selfOffsetX=0, selfOffsetY=-0.75, reverseIfNegativeScale=false, everyFrame=true)`

14. `BoolAllTrue(boolVariables=["$Wall Ahead","$Not Above Hero"], sendEvent="WALL", storeResult="None", everyFrame=true)`

15. `CheckYPositionV2(gameObject="Self", compareTo="$Land Y", compareToOffset=0, tolerance=0, equal=null, equalBool="None", lessThan=null, lessThanBool="$Below Ground", greaterThan=null, greaterThanBool="None", everyFrame=true, space=0, activeBool="None")`

16. `BoolAllTrue(boolVariables=["$Wall Ahead","$Below Ground"], sendEvent="WALL", storeResult="None", everyFrame=true)`



#### Downstab Land · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:410593>)

出口：FINISHED → Will Counter?；WALL → Wallcling。isSequence=0。

1. `GetPosition2d(gameObject="Self", vector_2d="None", x="$Self X", y="None", space=0, everyFrame=false)`

2. `FloatInRange(floatVariable="$Self X", lowerValue=81, upperValue=107, boolVariable="None", trueEvent=null, falseEvent="WALL", everyFrame=false)`

3. `SetPosition(gameObject="Self", vector="None", x="None", y="$Land Y", z="None", space=0, everyFrame=false, lateUpdate=false)`

4. `SendMessage(gameObject="Self", delivery=0, options=0, functionCall={"FunctionName":"StartConstrainX","parameterType":"None","BoolParameter":0,"FloatParameter":0,"IntParameter":0,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`

5. `SendMessage(gameObject="Self", delivery=0, options=0, functionCall={"FunctionName":"StartConstrainY","parameterType":"None","BoolParameter":0,"FloatParameter":0,"IntParameter":0,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`

6. `SetGravity2dScale(gameObject="Self", gravityScale="$Gravity")`

7. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Downstab End", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

8. `SetVelocity2d(gameObject="Self", vector="None", x="None", y=0, everyFrame=false)`

9. `DecelerateXY(gameObject="Self", decelerationX=0.8, decelerationY="None", brakeOnExit=true)`

10. `PlayParticleEmitterInState(gameObject="Owner($Pt Dust)")`

11. `SetBoolValue(boolVariable="$Do Pose", boolValue=1, everyFrame=false)`

12. `SetParticleEmission(gameObject="Owner($Pt DashDust)", emission=1, resetOnExit=true)`



#### Counter Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:411194>)

出口：FINISHED → Counter Dir。isSequence=0。

1. `SetBoolValue(boolVariable="$Will Counter", boolValue=0, everyFrame=false)`

2. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

3. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Counter Antic", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

4. `AudioPlayRandom(gameObject="$Self", audioClips=["GUID:483daa2893d30594791f0aa1d2604ff6#8300000","GUID:2e854a848e1a7de4b9d4aa14c2657d5e#8300000","GUID:42fe981215478324b950529fb49561bb#8300000"], weights=[1,1,1], pitchMin=1, pitchMax=1)`



#### Counter Stance · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:411384>)

出口：END → Counter End；BLOCKED HIT → Counter Hit。isSequence=0。

1. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:4de48443d6cc8a94da687bd4f0e12225#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

2. `SetInvincible(target="Self", Invincible=1, InvincibleFromDirection="$Invincibility Direction", resetOnStateExit=true)`

3. `Wait(time=0.75, finishEvent="END", realTime=false)`

4. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Counter Stance")`

5. `SendMessage(gameObject="Self", delivery=0, options=1, functionCall={"FunctionName":"flashFocusHeal","parameterType":"None","BoolParameter":0,"FloatParameter":0,"IntParameter":0,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`

6. `ActivateGameObject(gameObject="Owner($Counter Flash)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`



#### Counter End · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:411740>)

出口：FINISHED → Pose。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Counter End", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `SetBoolValue(boolVariable="$Do Pose", boolValue=0, everyFrame=false)`



#### Counter Hit · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:411840>)

出口：FINISHED → RapidSlash Charge。isSequence=0。

1. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Counter Hit", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `SendMessage(gameObject="Owner($GameManager)", delivery=0, options=1, functionCall={"FunctionName":"FreezeMoment","parameterType":"int","BoolParameter":0,"FloatParameter":0,"IntParameter":4,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`

4. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:123abd28c96813847b3c305fe3c3280a#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

5. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:6447a975892e6ac42be7525d74803f40#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

6. `AudioPlayRandom(gameObject="$Self", audioClips=["GUID:07cfbca00c2c93943957195119472d41#8300000","GUID:0c6f6cdab490fed42bac2ffbc9281320#8300000"], weights=[1,1], pitchMin=1, pitchMax=1)`

7. `ActivateGameObject(gameObject="Owner($Parry Clash Effect)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`



#### RapidSlash Charge · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:412286>)

出口：FINISHED → RapidSlash Loop；HERO COLLIDE → Collide To Multihit。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="RapidSlash Charge", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `SetVelocityByScale(gameObject="Self", speed=19, ySpeed="None", everyFrame=false)`

3. `SetDamageHeroAmount(target="Self", damageDealt=0)`

4. `Trigger2dEventLayer(trigger=0, collideTag="None", collideLayer=20, sendEvent="HERO COLLIDE", storeCollider="None")`

5. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:78dc29f3ceac6604dbe9830d100557ba#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="$Audio Player")`

6. `AudioPlayRandom(gameObject="$Self", audioClips=["GUID:0140219c7b48ab54a8a534595909b6d0#8300000"], weights=[1], pitchMin=1, pitchMax=1)`



#### RapidSlash Loop · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:412543>)

出口：FINISHED → RapidSlash End；MULTI HIT CONNECT → Hero Facing。isSequence=0。

1. `DecelerateXY(gameObject="Self", decelerationX=0.75, decelerationY="None", brakeOnExit=false)`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="RapidSlash Loop")`

3. `Wait(time=0.65, finishEvent="FINISHED", realTime=false)`

4. `SendEventByNameV2(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($CameraParent)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="SmallShake", delay=0, everyFrame=false)`

5. `ActivateGameObject(gameObject="Owner($MultiHit)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

6. `ActivateGameObject(gameObject="Owner($MultiHit)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

7. `SetPolygonCollider(gameObject="Owner($MultiHit)", active=1, resetOnExit=true)`

8. `ActivateGameObject(gameObject="Owner($RapidSlash Effect)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`



#### RapidSlash End · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:412826>)

出口：FINISHED → Pose。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="RapidSlash End", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `ActivateGameObject(gameObject="Owner($RapidSlash Effect)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

3. `SetDamageHeroAmount(target="Self", damageDealt=1)`

4. `SetBoolValue(boolVariable="$Do Pose", boolValue=0, everyFrame=false)`

5. `AudioPlayerOneShot(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClips=["GUID:6fd04435c3775f9498af8b7d580c7b35#8300000","GUID:7254d1843e0942d4cb0b0b7cc772589c#8300000","GUID:4ff9bf0f1a6507d41b1210a57219f83f#8300000","GUID:c36a66ca9a3b5ec4b846b59646ce6db2#8300000"], weights=[1,1,1,1], pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### ComboSlash 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:413062>)

出口：FINISHED → ComboSlash 2。isSequence=0。

1. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Combo Slash", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`

3. `AudioPlayRandom(gameObject="$Self", audioClips=["GUID:18da8b59f2deab34089376f058dfc862#8300000","GUID:e42242589c26af04ea5593439365a448#8300000","GUID:bd30188fa0366804c847d6a09afd44f3#8300000"], weights=[1,1,1], pitchMin=1, pitchMax=1)`

4. `PlayParticleEmitterInState(gameObject="Owner($Pt Dust)")`



#### ComboSlash 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:413246>)

出口：FINISHED → ComboSlash 3。isSequence=0。

1. `ActivateGameObject(gameObject="Owner($Combo Slash 1)", activate=1, recursive=0, resetOnExit=true, everyFrame=false)`

2. `ActivateGameObjectDelay(gameObject="Owner($Combo Slash 1)", activate=0, resetOnExit=false, delay=0.041)`

3. `SetVelocityByScale(gameObject="Self", speed=30, ySpeed="None", everyFrame=false)`

4. `SetParticleEmission(gameObject="Owner($Pt DashDust)", emission=1, resetOnExit=true)`

5. `Tk2dWatchAnimationEvents(gameObject="Self", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`

6. `AudioPlayerOneShot(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClips=["GUID:6fd04435c3775f9498af8b7d580c7b35#8300000","GUID:7254d1843e0942d4cb0b0b7cc772589c#8300000","GUID:4ff9bf0f1a6507d41b1210a57219f83f#8300000","GUID:c36a66ca9a3b5ec4b846b59646ce6db2#8300000"], weights=[1,1,1,1], pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

7. `AudioPlayRandom(gameObject="$Self", audioClips=["GUID:53153e6193c400f4ab51abad8310891a#8300000","GUID:d065e1a48d80ee044a15610d326796ae#8300000"], weights=[1,1], pitchMin=1, pitchMax=1)`

8. `PlayParticleEmitterInState(gameObject="Owner($Pt Dust)")`



#### ComboSlash 3 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:413567>)

出口：FINISHED → ComboSlash 4。isSequence=0。

1. **disabled** `SetVelocity2d(gameObject="Self", vector="None", x=0, y="None", everyFrame=false)`

2. `Tk2dWatchAnimationEvents(gameObject="Self", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`

3. `DecelerateXY(gameObject="Self", decelerationX=0.8, decelerationY="None", brakeOnExit=false)`

4. `PlayParticleEmitterInState(gameObject="Owner($Pt Dust)")`



#### ComboSlash 4 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:413713>)

出口：FINISHED → ComboSlash 5。isSequence=0。

1. `ActivateGameObject(gameObject="Owner($Combo Slash 2)", activate=1, recursive=0, resetOnExit=true, everyFrame=false)`

2. `ActivateGameObjectDelay(gameObject="Owner($Combo Slash 2)", activate=0, resetOnExit=false, delay=0.041)`

3. `SetVelocityByScale(gameObject="Self", speed=30, ySpeed="None", everyFrame=false)`

4. `SetParticleEmission(gameObject="Owner($Pt DashDust)", emission=1, resetOnExit=true)`

5. `Tk2dWatchAnimationEvents(gameObject="Self", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`

6. `AudioPlayerOneShot(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClips=["GUID:6fd04435c3775f9498af8b7d580c7b35#8300000","GUID:7254d1843e0942d4cb0b0b7cc772589c#8300000","GUID:4ff9bf0f1a6507d41b1210a57219f83f#8300000","GUID:c36a66ca9a3b5ec4b846b59646ce6db2#8300000"], weights=[1,1,1,1], pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

7. `AudioPlayRandom(gameObject="$Self", audioClips=["GUID:797c8d3bcc7af3e45bfda47c257c342c#8300000","GUID:b54a2bb0b2a9e1a4993c87964f0496c9#8300000","GUID:84c0d4151c3196a439836becc4444cca#8300000"], weights=[1,1,1], pitchMin=1, pitchMax=1)`

8. `PlayParticleEmitterInState(gameObject="Owner($Pt Dust)")`



#### ComboSlash 5 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:414043>)

出口：FINISHED → Will Counter?。isSequence=0。

1. **disabled** `SetVelocity2d(gameObject="Self", vector="None", x=0, y="None", everyFrame=false)`

2. `Tk2dWatchAnimationEvents(gameObject="Self", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `SetBoolValue(boolVariable="$Do Pose", boolValue=1, everyFrame=false)`

4. `DecelerateXY(gameObject="Self", decelerationX=0.8, decelerationY="None", brakeOnExit=true)`

5. `PlayParticleEmitterInState(gameObject="Owner($Pt Dust)")`



#### Distance Check · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:414206>)

出口：CLOSE → Close；FAR → Far；SING → Sing Antic。isSequence=0。

1. `CheckHeroPerformanceRegionV2(Target="Self", Radius=0, MinReactDelay=0, MaxReactDelay=0, None=null, ActiveInner="SING", ActiveOuter=null, IgnoreNeedolinRange=1, UseActiveBool=0, ActiveBool="None", StoreState="None", EveryFrame=true)`

2. `GetDistance(gameObject="Self", target="$Hero", storeResult="$Distance", everyFrame=false)`

3. `FloatCompare(float1="$Distance", float2=6, tolerance=0, equal="CLOSE", lessThan="CLOSE", greaterThan="FAR", everyFrame=false)`



#### Close · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:414409>)

出口：EVADE → Evade；COUNTER → Counter Antic；J SLASH → Charge Antic；COMBO → ComboSlash 1。isSequence=0。

1. `CheckAlertRange(alertRange="$Wall Range", storeResult="None", InRangeEvent="J SLASH", InRangeDelay=0, OutOfRangeEvent=null, OutOfRangeDelay=0, everyFrame=false)`

2. `SendRandomEventV3(events=["EVADE","COMBO","J SLASH"], weights=[1,1,1], trackingInts=["$Ct Evade","$Ct Combo","$Ct J Slash"], eventMax=[2,2,2], trackingIntsMissed=["$Ms Evade","$Ms Combo","$Ms J Slash"], missedMax=[4,4,4,5])`



#### Far · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:414665>)

出口：CHARGE → Hop To Charge；J SLASH → Hop To J Slash；COMBO → Hop To Combo。isSequence=0。

1. `SetIntValue(intVariable="$Hops", intValue=0, everyFrame=false)`

2. `CheckAlertRange(alertRange="$Wall Range", storeResult="None", InRangeEvent="J SLASH", InRangeDelay=0, OutOfRangeEvent=null, OutOfRangeDelay=0, everyFrame=false)`

3. `SendRandomEventV3(events=["COMBO","CHARGE","J SLASH"], weights=[1,1,1], trackingInts=["$Ct Combo","$Ct Charge","$Ct J Slash"], eventMax=[2,1,2], trackingIntsMissed=["$Ms Combo","$Ms Charge","$Ms J Slash"], missedMax=[4,4,4])`



#### Evade · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:414922>)

出口：FINISHED → Evade Recover。isSequence=0。

1. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

2. `SetVelocityByScale(gameObject="Self", speed=-30, ySpeed="None", everyFrame=false)`

3. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Evade", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`

4. `AudioPlayerOneShot(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClips=["GUID:5612842bd9c91d54ca36821974b6eeb9#8300000","GUID:9156961f29e23534aaf1cb3053337526#8300000","GUID:6d0241d0624997e48ad3c91b42bcb3d8#8300000","GUID:0a03f8b9434c4a9469fe976a81948350#8300000"], weights=[1,1,1,1], pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

5. `AudioPlayRandom(gameObject="$Self", audioClips=["GUID:d2f0567df30ee22479d39ac4239db549#8300000","GUID:2e854a848e1a7de4b9d4aa14c2657d5e#8300000","GUID:797c8d3bcc7af3e45bfda47c257c342c#8300000"], weights=[1,1,1], pitchMin=1, pitchMax=1)`



#### Evade Recover · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:415212>)

出口：FINISHED → Evade Move。isSequence=0。

1. `SetVelocity2d(gameObject="Self", vector="None", x=0, y="None", everyFrame=false)`

2. `Tk2dWatchAnimationEvents(gameObject="Self", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`



#### Evade Move · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:415321>)

出口：J SLASH → J Slash Antic；CHARGE → Charge Antic；COMBO → Hop To Combo；CROSS SLASH → CrossSlash Aim。isSequence=0。

1. `BoolTest(boolVariable="$Will CrossSlash", isTrue="CROSS SLASH", isFalse=null, everyFrame=false)`

2. `SendRandomEvent(events=["COMBO","CHARGE","J SLASH"], weights=[1,1,1], delay=0)`



#### Hop Check · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:415463>)

出口：HOP END → Hop End；FINISHED → Hop Antic。isSequence=0。

1. `GetXDistance(gameObject="Self", target="$Hero", storeResult="$Distance", everyFrame=false)`

2. `FloatCompare(float1="$Distance", float2="$Target Distance", tolerance=0, equal="HOP END", lessThan="HOP END", greaterThan=null, everyFrame=false)`

3. `CheckAlertRange(alertRange="$Wall Range", storeResult="None", InRangeEvent="FINISHED", InRangeDelay=0, OutOfRangeEvent=null, OutOfRangeDelay=0, everyFrame=false)`

4. `IntCompare(integer1="$Hops", integer2=3, equal=null, lessThan=null, greaterThan="HOP END", everyFrame=false)`



#### Hop To Charge · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:415648>)

出口：FINISHED → Hop Check。isSequence=0。

1. `SetFloatValue(floatVariable="$Target Distance", floatValue=16, everyFrame=false)`

2. `SetStringValue(stringVariable="$Next Event", stringValue="CHARGE", everyFrame=false)`



#### Hop To J Slash · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:415743>)

出口：FINISHED → Hop Check。isSequence=0。

1. `SetFloatValue(floatVariable="$Target Distance", floatValue=12, everyFrame=false)`

2. `SetStringValue(stringVariable="$Next Event", stringValue="J SLASH", everyFrame=false)`



#### Hop To Combo · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:415838>)

出口：FINISHED → Hop Check。isSequence=0。

1. `SetFloatValue(floatVariable="$Target Distance", floatValue=9.25, everyFrame=false)`

2. `SetStringValue(stringVariable="$Next Event", stringValue="COMBO", everyFrame=false)`



#### Hop End · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:415933>)

出口：CHARGE → Charge Antic；J SLASH → J Slash Antic；COMBO → ComboSlash 1。isSequence=0。

1. `SendEventByName(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="$Next Event", delay=0, everyFrame=false)`



#### Hop Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:416062>)

出口：FINISHED → Hop。isSequence=0。

1. `IntAdd(intVariable="$Hops", add=1, everyFrame=false)`

2. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

3. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Forward Hop", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`



#### Hop · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:416198>)

出口：FINISHED → Hop Recover。isSequence=0。

1. `SetVelocityByScale(gameObject="Self", speed=24, ySpeed="None", everyFrame=false)`

2. `Tk2dWatchAnimationEvents(gameObject="Self", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`

3. `AudioPlayerOneShot(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClips=["GUID:5612842bd9c91d54ca36821974b6eeb9#8300000","GUID:9156961f29e23534aaf1cb3053337526#8300000","GUID:6d0241d0624997e48ad3c91b42bcb3d8#8300000","GUID:0a03f8b9434c4a9469fe976a81948350#8300000"], weights=[1,1,1,1], pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

4. `PlayParticleEmitterInState(gameObject="Owner($Pt Dust)")`



#### Hop Recover · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:416402>)

出口：FINISHED → Hop Check。isSequence=0。

1. `Tk2dWatchAnimationEvents(gameObject="Self", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `DecelerateXY(gameObject="Self", decelerationX=0.75, decelerationY="None", brakeOnExit=true)`

3. `PlayParticleEmitterInState(gameObject="Owner($Pt Dust)")`



#### Will Counter? · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:416515>)

出口：FINISHED → Pose。isSequence=0。

1. `SendRandomEvent(events=[null,"FINISHED"], weights=[0.33,0.66], delay=0)`

2. `SetBoolValue(boolVariable="$Will Counter", boolValue=1, everyFrame=false)`



#### Dormant · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:416624>)

出口：ENTER → Scene Start；BLOCKED HIT → Block Voice。isSequence=0。

1. `SetIsKinematic2d(gameObject="Self", isKinematic=1)`

2. `SetLayer(gameObject="Self", layer=2)`

3. `ActivateGameObject(gameObject="Owner($Attack Detector)", activate=1, recursive=0, resetOnExit=true, everyFrame=false)`

4. `SetRandomAudioClipFromTable(Table="GUID:17354c8b437ed424bb214508071a17b0#11400000", AudioSource="$Audio Loop Voice", AutoPlay=1, delay=0)`

5. `ReceivedDamage(Target="Owner($Attack Detector)", collideTag="None", sendEvent="BLOCKED HIT", sendEventHeavy=null, sendEventSpikes=null, sendEventLava=null, sendEventLightning=null, storeGameObject="None", ignoreAcid=0, ignoreLava=0, ignoreWater=0, ignoreHunterWeapon=0, ignoreTraps=0, ignoreNail=0, ignoreSpikes=0, storeDamageDealt="None", storeDirection="None", storeMagnitudeMultiplier="None", firstHitOnly=0)`



#### Encountered? · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:416894>)

出口：MEET → Take Control；REFIGHT → Refight。isSequence=0。

1. `PlayerDataBoolTest(boolName="encounteredLace1", isTrue="REFIGHT", isFalse="MEET")`



#### Take Control · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:416977>)

出口：LAND → Wait。isSequence=0。

1. `BoolTest(boolVariable="$Dormant Block", isTrue="LAND", isFalse=null, everyFrame=false)`

2. `TransitionToAudioSnapshot(snapshot="GUID:1e5b83863824c3e46b1a27345f960db5#24500034", transitionTime=6)`

3. `SetPlayerDataBool(boolName="disablePause", value=1)`

4. `SetPlayerDataBool(boolName="isInvincible", value=1)`

5. **disabled** `ClampPosition(gameObject="Owner($Hero)", minX="None", maxX=92.75, minY="None", maxY="None", minZ="None", maxZ="None", space=0, everyFrame=true, lateUpdate=false)`

6. `RunFSM(fsmTemplateControl={"targetType":0,"target":"GUID:6acb65dd9070fec409d4a74210794792#11400000","inputVariables":[{"variable":"$Clamp X","fsmVar":{"variableName":null,"objectType":"UnityEngine.Object","useVariable":0,"type":0,"floatValue":92.75,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}},"isEdited":0}],"outputVariables":[],"outputEvents":[]}, finishEvent="LAND", everyFrame=false)`



#### Scene Start · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:417200>)

出口：FINISHED → Location Check。isSequence=0。

1. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Battle Gates)","fsmName":null,"sendToChildren":1,"fsmComponent":"fileID:0"}, sendEvent="BG CLOSE", delay=0, everyFrame=false)`

2. `ActivateGameObject(gameObject="Owner($Battle Scene)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`



#### Convo 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:417338>)

出口：CONVO_END → Conduct End。isSequence=0。

1. `AudioStopV2(gameObject="Owner($Audio Loop Voice)", fadeTime=0, cancelOnEarlyExit=false)`

2. `RunDialogue(Sheet="Wanderers", Key="LACE_MEET_1", OverrideContinue=1, PlayerVoiceTableOverride="fileID:0", PreventHeroAnimation=0, HideDecorators=0, TextAlignment=0, OffsetY=0, Target="Self")`

3. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:18326e1ca471d7f489bf2967d888ebc2#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Convo 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:417546>)

出口：CONVO_END → Convo 3。isSequence=0。

1. `RunDialogue(Sheet="Wanderers", Key="LACE_MEET_2", OverrideContinue=0, PlayerVoiceTableOverride="GUID:d0211822fbd355d4c872fb45b1c6d0c4#11400000", PreventHeroAnimation=0, HideDecorators=0, TextAlignment=0, OffsetY=0, Target="Self")`

2. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Silkflies)","fsmName":null,"sendToChildren":1,"fsmComponent":"fileID:0"}, sendEvent="LEAVE", delay=0, everyFrame=false)`

3. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:483daa2893d30594791f0aa1d2604ff6#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Convo 4 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:417785>)

出口：CONVO_END → End Dialogue。isSequence=0。

1. `SetPlayerDataBool(boolName="encounteredLace1", value=1)`

2. `Tk2dPlayAnimation(gameObject="Owner($Hero)", animLibName=null, clipName="Challenge Talk Idle")`

3. `RunDialogue(Sheet="Wanderers", Key="LACE_MEET_4", OverrideContinue=0, PlayerVoiceTableOverride="fileID:0", PreventHeroAnimation=1, HideDecorators=0, TextAlignment=0, OffsetY=0, Target="Self")`

4. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:913122a8f5e67b949929bdc08043d936#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Start Battle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:418015>)

出口：FINISHED → Evade。isSequence=0。

1. `TransitionToAudioSnapshot(snapshot="GUID:1e5b83863824c3e46b1a27345f960db5#24500036", transitionTime=0)`

2. `ApplyMusicCue(musicCue="GUID:5688bd61df4e4a94eabfb5903c3475df#11400000", delayTime=0, transitionTime=0)`

3. `SetInvincible(target="Self", Invincible=0, InvincibleFromDirection=0, resetOnStateExit=false)`

4. `DisplayBossTitle(areaTitleObject="$AreaTitle", displayRight=1, bossTitle="LACE")`

5. `SetIsKinematic2d(gameObject="Self", isKinematic=0)`

6. `SetLayer(gameObject="Self", layer=11)`



#### End Dialogue · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:418196>)

出口：FINISHED → End Dialogue 2。isSequence=0。

1. `SetPlayerDataBool(boolName="isInvincible", value=0)`

2. `Tk2dPlayAnimationWait(Target="Owner($Hero)", ClipName="Challenge Talk End", AnimationCompleteEvent=null)`

3. `EndDialogue(ReturnControl=0, ReturnHUD=1, Target="Self", UseChildren=0)`

4. `Wait(time=0.3, finishEvent=null, realTime=false)`



#### Refight · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:418337>)

出口：FINISHED → Start Battle。isSequence=0。

1. `AudioPlayRandomVoiceFromTable(gameObject="Self", audioClipTable="GUID:7e4a21cd4cc147c4084b1a0bc7f1a1bd#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="TurnToIdle")`

3. `AudioStopV2(gameObject="Owner($Audio Loop Voice)", fadeTime=0, cancelOnEarlyExit=false)`

4. `Wait(time=0.15, finishEvent="FINISHED", realTime=false)`

5. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Silkflies)","fsmName":null,"sendToChildren":1,"fsmComponent":"fileID:0"}, sendEvent="LEAVE", delay=0, everyFrame=false)`



#### Stun Start · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:418526>)

出口：FINISHED → Stun Air。isSequence=0。

1. `AudioStop(gameObject="Owner($Audio Player)", fadeTime=0)`

2. `SendMessage(gameObject="Self", delivery=0, options=0, functionCall={"FunctionName":"EndConstrain","parameterType":"None","BoolParameter":0,"FloatParameter":0,"IntParameter":0,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`

3. `SetRecoilSpeed(target="Self", newRecoilSpeed=7)`

4. `SetFloatValue(floatVariable="$Stun Timer", floatValue=2, everyFrame=false)`

5. `SetGravity2dScale(gameObject="Self", gravityScale="$Gravity")`

6. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

7. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Stun Air")`

8. `SetVelocityByScale(gameObject="Self", speed=-6, ySpeed=23, everyFrame=false)`

9. `NextFrameEvent(sendEvent="FINISHED")`

10. `ActivateGameObject(gameObject="Owner($Circle Slash 1)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

11. `ActivateGameObject(gameObject="Owner($Circle Slash 2)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

12. `ActivateGameObject(gameObject="Owner($Combo Slash 1)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

13. `ActivateGameObject(gameObject="Owner($Combo Slash 2)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

14. `ActivateGameObject(gameObject="Owner($Charge Hit)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

15. `ActivateGameObject(gameObject="Owner($Downstab Hit)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

16. `SetPolygonCollider(gameObject="Owner($MultiHit)", active=0, resetOnExit=false)`

17. `ActivateGameObject(gameObject="Owner($RapidSlash Effect)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

18. `ActivateGameObject(gameObject="Owner($CrossSlash Energy)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

19. `ActivateGameObject(gameObject="Owner($Leap Burst)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

20. `AudioPlayRandom(gameObject="$Self", audioClips=["GUID:84c0d4151c3196a439836becc4444cca#8300000","GUID:d82edb01e9759d547b7cfe48f514f8d5#8300000","GUID:bff3d05c77c4c3048a487db5da624e80#8300000"], weights=[1,1,1], pitchMin=1, pitchMax=1)`

21. `SetHitEffectOrigin(target="Self", effectOrigin={"x":0,"y":-0.61,"z":0}, everyFrame=false)`

22. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Hero)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="WOUND END", delay=0, everyFrame=false)`



#### Stun Air · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:419271>)

出口：LAND → Stun Land。isSequence=0。

1. `CheckCollisionSideEnter(topHit="None", rightHit="None", bottomHit="None", leftHit="None", topHitEvent=null, rightHitEvent=null, bottomHitEvent="LAND", leftHitEvent=null, otherLayer=false, otherLayerNumber=0, ignoreTriggers=0)`

2. `CheckCollisionSide(collidingObject="Self", topHit="None", rightHit="None", bottomHit="None", leftHit="None", topHitEvent=null, rightHitEvent=null, bottomHitEvent="LAND", leftHitEvent=null, otherLayer=false, otherLayerNumber=0, ignoreTriggers=0)`

3. `SetDamageHeroAmount(target="Self", damageDealt=0)`

4. `SetSpecialDeath(target="Self", hasSpecialDeath=1)`



#### Stunned · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:419471>)

出口：END → Stun Recover；TOOK DAMAGE → Stun Damage；SING → Sing Antic。isSequence=0。

1. `DecelerateXY(gameObject="Self", decelerationX=0.85, decelerationY="None", brakeOnExit=false)`

2. `FloatAdd(floatVariable="$Stun Timer", add=-1, everyFrame=true, perSecond=true)`

3. `FloatCompare(float1="$Stun Timer", float2=0, tolerance=0, equal="END", lessThan="END", greaterThan=null, everyFrame=true)`

4. `CheckHeroPerformanceRegion(Target="Self", MinReactDelay=0.5, MaxReactDelay=0.5, None=null, ActiveInner="SING", ActiveOuter=null, IgnoreNeedolinRange=0, useActiveBool=false, ActiveBool="None", StoreState="None", EveryFrame=true)`



#### Stun Recover · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:419679>)

出口：FINISHED → Pose。isSequence=0。

1. `SetRecoilSpeed(target="Self", newRecoilSpeed=15)`

2. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="STUN CONTROL START", delay=0, everyFrame=false)`

3. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Stun Recover", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

4. `SetBoolValue(boolVariable="$Do Pose", boolValue=0, everyFrame=false)`

5. `AudioStop(gameObject="Self", fadeTime=0)`

6. `AudioPlayRandom(gameObject="$Self", audioClips=["GUID:c89c542a80f207a448a4637d46ad2acb#8300000"], weights=[1], pitchMin=1, pitchMax=1)`



#### CrossSlash Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:419901>)

出口：ATTACK → CrossSlash。isSequence=0。

1. `SetIntValue(intVariable="$Evade Attempts", intValue=0, everyFrame=false)`

2. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($CameraParent)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="EnemyKillShake", delay=0, everyFrame=false)`

3. `RandomInt(min=2, max=4, storeResult="$Ct CrossSlash", inclusiveMax=true, noRepeat=0)`

4. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="CrossSlash Antic")`

5. `SetRecoilSpeed(target="Self", newRecoilSpeed=0)`

6. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="STUN CONTROL STOP", delay=0, everyFrame=false)`

7. `ActivateGameObject(gameObject="Owner($CrossSlash Obj)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

8. `ActivateGameObject(gameObject="Owner($CrossSlash Energy)", activate=1, recursive=0, resetOnExit=true, everyFrame=false)`

9. `Wait(time=0.9, finishEvent="ATTACK", realTime=false)`

10. `ActivateGameObject(gameObject="Owner($Eye Flash)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

11. `AudioPlayRandom(gameObject="$Self", audioClips=["GUID:d2f0567df30ee22479d39ac4239db549#8300000","GUID:2e854a848e1a7de4b9d4aa14c2657d5e#8300000","GUID:797c8d3bcc7af3e45bfda47c257c342c#8300000"], weights=[1,1,1], pitchMin=1, pitchMax=1)`



#### CrossSlash · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:420300>)

出口：NEXT → Finish Multihit。isSequence=0。

1. `SetIsKinematic2d(gameObject="Self", isKinematic=1)`

2. `SetSpecialDeath(target="Self", hasSpecialDeath=1)`

3. `SetMeshRenderer(gameObject="Self", active=0)`

4. `SetCollider(gameObject="Self", active=0, resetOnExit=false)`

5. `Wait(time=0.8, finishEvent="NEXT", realTime=false)`

6. `AudioPlayerOneShotSingle(audioPlayer="GUID:e8466d04a5c03bc4b8d6a0838af84de7#1709254077376921", spawnPoint="$Self", audioClip="GUID:0ad66b89692dc8847a9af2c0a74c6645#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

7. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($CrossSlash Obj)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="ATTACK START", delay=0, everyFrame=false)`

8. `AudioPlayRandom(gameObject="$Self", audioClips=["GUID:b13cee3b92cd5b64a9a17c90abcee75a#8300000"], weights=[1], pitchMin=1, pitchMax=1)`

9. `SetPositionToObject2D(gameObject="Owner($CS Sprite Follower)", targetObject="$CS Lace Sprite", xOffset=0, yOffset=0, everyFrame=true)`

10. `GetPosition(gameObject="Owner($CS Sprite Follower)", vector="$CS Lace Pos", x="None", y="None", z="None", space=1, everyFrame=true)`

11. `SetHitEffectOrigin(target="Self", effectOrigin="$CS Lace Pos", everyFrame=true)`



#### Slash Slam · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:420684>)

出口：NEXT → Pose。isSequence=0。

1. `Translate(gameObject="Owner($MainCamera)", vector="None", x="None", y=-0.3, z="None", space=0, perSecond=false, everyFrame=false, lateUpdate=false, fixedUpdate=false)`

2. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:4fd25025a4c692348844711355906d5f#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

3. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($CameraParent)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="AverageShake", delay=0.01, everyFrame=false)`

4. `SetRecoilSpeed(target="Self", newRecoilSpeed=15)`

5. `SetSpecialDeath(target="Self", hasSpecialDeath=0)`

6. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Downstab End", animationTriggerEvent=null, animationCompleteEvent="NEXT")`

7. `ActivateGameObject(gameObject="Owner($CrossSlash Obj)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

8. `ActivateGameObject(gameObject="Owner($Slam Effect)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

9. `SetIsKinematic2d(gameObject="Self", isKinematic=0)`

10. `SetMeshRenderer(gameObject="Self", active=1)`

11. `SetCollider(gameObject="Self", active=1, resetOnExit=false)`

12. `SetPositionToObject(gameObject="Self", targetObject="$CS Exit Point", xOffset=0, yOffset=0, zOffset=0, overrideZ="None", everyFrame=false)`

13. `PlayParticleEmitterChildren(gameObject="Owner($Slam Particles)", resetTimeIfPlaying=false, stopOnStateExit=false)`

14. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="STUN CONTROL START", delay=0, everyFrame=false)`

15. `SetBoolValue(boolVariable="$Do Pose", boolValue=1, everyFrame=false)`



#### CrossSlash? · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:421192>)

出口：CROSS SLASH → CrossSlash Aim；FINISHED → Distance Check。isSequence=0。

1. **disabled** `SendEvent(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="CROSS SLASH", delay=0, everyFrame=false)`

2. `CompareHP(enemy="$Self", integer2="$Rage HP", equal=null, lessThan=null, greaterThan="FINISHED", everyFrame=false)`

3. `IntCompare(integer1="$Ct CrossSlash", integer2=0, equal="CROSS SLASH", lessThan="CROSS SLASH", greaterThan=null, everyFrame=false)`

4. `IntAdd(intVariable="$Ct CrossSlash", add=-1, everyFrame=false)`



#### CrossSlash Aim · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:421370>)

出口：FINISHED → CrossSlash Antic；EVADE → CS Evade。isSequence=0。

1. `SetBoolValue(boolVariable="$Will CrossSlash", boolValue=0, everyFrame=false)`

2. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

3. `GetXDistance(gameObject="Self", target="$Hero", storeResult="$Distance", everyFrame=false)`

4. `FloatCompare(float1="$Distance", float2=6, tolerance=0, equal=null, lessThan="EVADE", greaterThan=null, everyFrame=false)`

5. `GetPosition(gameObject="Self", vector="None", x="$Self X", y="None", z="None", space=0, everyFrame=false)`

6. `FloatTestToBool(float1="$Self X", float2="$Centre X", tolerance=0, equalBool="None", lessThanBool="None", greaterThanBool="$Right Side", everyFrame=false)`

7. `GetScale(gameObject="Self", vector="None", xScale="$X Scale", yScale="None", zScale="None", space=0, everyFrame=false)`

8. `FloatTestToBool(float1="$X Scale", float2=0, tolerance=0, equalBool="None", lessThanBool="None", greaterThanBool="$Facing Right", everyFrame=false)`

9. `BoolTestMulti(boolVariables=["$Facing Right","$Right Side"], boolStates=[1,1], trueEvent="EVADE", falseEvent=null, storeResult="None", everyFrame=false)`

10. `BoolTestMulti(boolVariables=["$Facing Right","$Right Side"], boolStates=[0,0], trueEvent="EVADE", falseEvent=null, storeResult="None", everyFrame=false)`

11. `AudioPlayerOneShotSingle(audioPlayer="GUID:e8466d04a5c03bc4b8d6a0838af84de7#1709254077376921", spawnPoint="$Self", audioClip="GUID:4a1c3fefe4b6fc94881259743cb0e7c1#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

12. `AudioPlayRandom(gameObject="$Self", audioClips=["GUID:797c8d3bcc7af3e45bfda47c257c342c#8300000"], weights=[1], pitchMin=1, pitchMax=1)`



#### CS Evade · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:421908>)

出口：FINISHED → Evade；END → CS Evade Cancel。isSequence=0。

1. `SetBoolValue(boolVariable="$Will CrossSlash", boolValue=1, everyFrame=false)`

2. `IntAdd(intVariable="$Evade Attempts", add=1, everyFrame=false)`

3. `IntCompare(integer1="$Evade Attempts", integer2=2, equal="END", lessThan=null, greaterThan="END", everyFrame=false)`



#### CS Evade Cancel · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:422035>)

出口：FINISHED → CrossSlash Antic。isSequence=0。

1. `SetScale(gameObject="Self", vector="None", x=1, y="None", z="None", everyFrame=false, lateUpdate=false)`

2. `GetPosition(gameObject="Self", vector="None", x="$Self X", y="None", z="None", space=0, everyFrame=false)`

3. `AudioPlayerOneShotSingle(audioPlayer="GUID:e8466d04a5c03bc4b8d6a0838af84de7#1709254077376921", spawnPoint="$Self", audioClip="GUID:4a1c3fefe4b6fc94881259743cb0e7c1#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

4. `AudioPlayRandom(gameObject="$Self", audioClips=["GUID:797c8d3bcc7af3e45bfda47c257c342c#8300000"], weights=[1], pitchMin=1, pitchMax=1)`

5. `FloatCompare(float1="$Self X", float2="$Centre X", tolerance=0, equal=null, lessThan="FINISHED", greaterThan=null, everyFrame=false)`

6. `SetScale(gameObject="Self", vector="None", x=-1, y="None", z="None", everyFrame=false, lateUpdate=false)`



#### Multihitting · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:422344>)

出口：FINISHED → Multihit Slash。isSequence=0。

1. `SetVelocity2d(gameObject="Self", vector={"x":0,"y":0}, x="None", y="None", everyFrame=false)`

2. `SetVelocity2d(gameObject="Owner($Hero)", vector={"x":0,"y":0}, x="None", y="None", everyFrame=true)`

3. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:7802b4d32e14ea04c817cc4b09415866#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="$Audio Player")`

4. `DoCameraShake(VisibleRenderer="Self", Camera="GUID:9b0888e0916dca544846a2f34304dac9#11400000", Profile="GUID:e483858fc9bec004c905f955c1162848#11400000", cancelOnExit=false, DoFreeze=1, Delay=0)`

5. `GetPosition(gameObject="Owner($Multihit Point)", vector="$Multihit Pos", x="None", y="None", z="None", space=0, everyFrame=false)`

6. `SetVector3XYZ(vector3Variable="$Multihit Pos", vector3Value="None", x="None", y="None", z=0.004, everyFrame=false)`

7. `AnimatePositionTo(gameObject="Owner($Hero)", toValue="$Multihit Pos", localSpace=false, time=0.15, speed="None", delay="None", easeType=13, reverse=0, finishEvent=null, realTime=false)`

8. `PlayParticleEmitterInState(gameObject="Owner($Pt RapidSlash)")`

9. `Wait(time=0.75, finishEvent="FINISHED", realTime=false)`



#### Multihit Slash · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:422725>)

出口：FINISHED → Pose。isSequence=0。

1. `Translate(gameObject="Owner($Hero)", vector="None", x="None", y=0.5, z="None", space=0, perSecond=false, everyFrame=false, lateUpdate=false, fixedUpdate=false)`

2. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:01d2b5fd812bfd744b98acf529f25c5f#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="$Audio Player")`

3. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:74bb195a54383bd4a8a898a864ace681#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

4. `ActivateGameObject(gameObject="Owner($RapidSlash Effect)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

5. `CancelCameraShake(Camera="GUID:9b0888e0916dca544846a2f34304dac9#11400000", Profile="GUID:e483858fc9bec004c905f955c1162848#11400000")`

6. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="MultiHit Slash", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

7. `DamageHeroDirectly(damager="Self", damageAmount=1, spikeHazard=false, sinkHazard=false)`

8. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($MultiHit)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="MULTIHIT END", delay=0, everyFrame=false)`

9. `SetDamageHeroAmount(target="Self", damageDealt=1)`

10. `SetBoolValue(boolVariable="$Do Pose", boolValue=1, everyFrame=false)`



#### Hero Facing · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:423120>)

出口：FINISHED → Multihitting。isSequence=0。

1. `SendMessage(gameObject="Owner($Hero)", delivery=0, options=1, functionCall={"FunctionName":"FaceRight","parameterType":"None","BoolParameter":0,"FloatParameter":0,"IntParameter":0,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`

2. `CheckTargetDirection(gameObject="Self", target="$Hero", aboveEvent=null, belowEvent=null, rightEvent=null, leftEvent="FINISHED", aboveBool="None", belowBool="None", rightBool="None", leftBool="None", selfOffsetX=0, selfOffsetY=0, reverseIfNegativeScale=false, everyFrame=false)`

3. `SendMessage(gameObject="Owner($Hero)", delivery=0, options=1, functionCall={"FunctionName":"FaceLeft","parameterType":"None","BoolParameter":0,"FloatParameter":0,"IntParameter":0,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`



#### Collide To Multihit · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:423525>)

出口：FINISHED → Hero Facing；CANCEL → Collide Cancel；BIND BELL → Bind Bell Damage。isSequence=0。

1. `CallMethodProper(gameObject="Owner($Hero)", behaviour="HeroController", methodName="WillDoBellBindHit", parameters=[], storeResult={"variableName":"Bind Bell Hit","objectType":"UnityEngine.Object","useVariable":1,"type":2,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}, EveryFrame=false)`

2. `BoolTest(boolVariable="$Bind Bell Hit", isTrue="BIND BELL", isFalse=null, everyFrame=false)`

3. `CanHeroTakeDamage(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, canTakeDmgEvent=null, cannotTakeDmgEvent="CANCEL")`

4. `CallMethodProper(gameObject="Owner($Hero)", behaviour="HeroController", methodName="TakeQuickDamage", parameters=[{"variableName":null,"objectType":"UnityEngine.Object","useVariable":0,"type":1,"floatValue":0,"intValue":1,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}},{"variableName":null,"objectType":"UnityEngine.Object","useVariable":0,"type":2,"floatValue":0,"intValue":0,"boolValue":1,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}], storeResult={"variableName":null,"objectType":"UnityEngine.Object","useVariable":1,"type":-1,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}, EveryFrame=false)`

5. `SendEventToRegister(eventName="HERO DAMAGED")`

6. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Hero)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="WOUND START", delay=0, everyFrame=false)`

7. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="RapidSlash Loop")`

8. `SendEventByNameV2(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($CameraParent)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="SmallShake", delay=0, everyFrame=false)`

9. `ActivateGameObject(gameObject="Owner($RapidSlash Effect)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`



#### Pose · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:423974>)

出口：FINISHED → Idle；SWISH → Pose Swish；LEAN → Pose Lean；UPRIGHT → Pose Upright；HORNET DEAD → Death Pose。isSequence=0。

1. `BoolTest(boolVariable="$Hornet Dead", isTrue="HORNET DEAD", isFalse=null, everyFrame=false)`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Idle")`

3. `BoolTest(boolVariable="$Do Pose", isTrue=null, isFalse="FINISHED", everyFrame=false)`

4. `SendRandomEvent(events=["SWISH","LEAN","UPRIGHT"], weights=[1,1,1], delay=0)`



#### Finish Multihit · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:424164>)

出口：FINISHED → Slash Slam。isSequence=0。

1. `SetHitEffectOrigin(target="Self", effectOrigin={"x":0,"y":-0.61,"z":0}, everyFrame=false)`

2. `BoolTest(boolVariable="$CrossSlashing Hero", isTrue=null, isFalse="FINISHED", everyFrame=false)`

3. `SetBoolValue(boolVariable="$CrossSlashing Hero", boolValue=0, everyFrame=false)`

4. `SetMeshRenderer(gameObject="Owner($Hero)", active=1)`

5. `SetPositionToObject(gameObject="Owner($Hero)", targetObject="$CS Slam Point", xOffset=0, yOffset=0.75, zOffset=0, overrideZ="None", everyFrame=false)`

6. `SetPosition(gameObject="Owner($Hero)", vector="None", x="None", y="None", z=0.004, space=0, everyFrame=false, lateUpdate=false)`

7. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:96a43b099041dd44186d45aa7bdb453d#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

8. `DamageHeroDirectly(damager="Self", damageAmount=1, spikeHazard=false, sinkHazard=false)`

9. `CancelCameraShake(Camera="GUID:9b0888e0916dca544846a2f34304dac9#11400000", Profile="GUID:e483858fc9bec004c905f955c1162848#11400000")`

10. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`



#### Stun Land · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:424515>)

出口：FINISHED → Stunned。isSequence=0。

1. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Stun")`

2. `SetSpecialDeath(target="Self", hasSpecialDeath=0)`

3. `SetVelocity2d(gameObject="Self", vector="None", x="None", y=0, everyFrame=false)`

4. `SetAudioClip(gameObject="Self", audioClip="GUID:653dc91e566beeb4b9c27ba698092505#8300000", autoPlay=1, stopOnExit=0)`

5. **disabled** `AudioPlaySimple(gameObject="Self", volume=1, oneShotClip="fileID:0")`

6. `SetDamageHeroAmount(target="Self", damageDealt=1)`

7. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:f5535cec80d90614ea1e0ffa2a930edd#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

8. `SendMessage(gameObject="Self", delivery=0, options=0, functionCall={"FunctionName":"StartConstrainX","parameterType":"None","BoolParameter":0,"FloatParameter":0,"IntParameter":0,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`

9. `SendMessage(gameObject="Self", delivery=0, options=0, functionCall={"FunctionName":"StartConstrainY","parameterType":"None","BoolParameter":0,"FloatParameter":0,"IntParameter":0,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`



#### Stun Damage · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:425062>)

出口：FINISHED → Stunned；END → Damage Recover。isSequence=0。

1. `AudioStop(gameObject="Self", fadeTime=0)`

2. `PlayAudioEventRandom(audioClips={"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":12,"objectTypeName":"UnityEngine.AudioClip","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":["GUID:84c0d4151c3196a439836becc4444cca#8300000","GUID:6cc22cdc43b17a44989db47b7908484d#8300000","GUID:4dfed740846c2f04b8d54630e5f40a6a#8300000"]}, pitchMin=1, pitchMax=1, volume=1, audioPlayerPrefab="None", spawnPoint="Self", spawnPosition={"x":0,"y":0,"z":0}, SpawnedPlayerRef="None")`

3. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

4. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Stun Hit")`

5. `Tk2dPlayFrame(gameObject="Self", frame=0)`

6. `FloatAdd(floatVariable="$Stun Timer", add=-0.25, everyFrame=false, perSecond=false)`

7. `FloatCompare(float1="$Stun Timer", float2=0, tolerance=0, equal="END", lessThan="END", greaterThan="FINISHED", everyFrame=false)`



#### Damage Recover · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:425348>)

出口：FINISHED → Stun Recover。isSequence=0。

1. `SendEventByName(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="EnemyKillShake", delay=0, everyFrame=false)`

2. `SendMessage(gameObject="Owner($GameManager)", delivery=0, options=1, functionCall={"FunctionName":"FreezeMoment","parameterType":"int","BoolParameter":0,"FloatParameter":0,"IntParameter":1,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`



#### Charge Break · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:425596>)

出口：NEXT → Charge。isSequence=0。

1. `SetVelocity2d(gameObject="Self", vector="None", x=0, y="None", everyFrame=false)`

2. `Wait(time=0.6, finishEvent="NEXT", realTime=false)`



#### Counter Dir · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:425702>)

出口：FINISHED → Counter Stance。isSequence=0。

1. `SetIntValue(intVariable="$Invincibility Direction", intValue=9, everyFrame=false)`

2. `SendEventByScale(gameObject="Self", eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, xScale=true, positiveEvent="FINISHED", negativeEvent=null, space=0)`

3. `SetIntValue(intVariable="$Invincibility Direction", intValue=8, everyFrame=false)`



#### Pose Swish · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:425847>)

出口：FINISHED → Pose Swish 2；CANCEL → Pose Lean。isSequence=0。

1. `CheckAlertRangeByName(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, alertRangeName="NoThwhip Range", storeResult=0, sendEvent="CANCEL", outOfRangeEvent=null, everyFrame=false)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Pose Swish", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`

3. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:678914bbb7434984faf936c8f82a81e1#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

4. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.0)`



#### Pose Lean · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:426093>)

出口：FINISHED → Idle。isSequence=0。

1. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Pose Lean")`

2. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:52619d34fd2aee941984f87fc9cf0609#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

3. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.0)`



#### Pose Upright · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:426274>)

出口：FINISHED → Idle。isSequence=0。

1. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Pose Upright")`

2. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:7a107aa1fe3243b409f187b6097a840c#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Pose Swish 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:426419>)

出口：FINISHED → Idle。isSequence=0。

1. `Tk2dWatchAnimationEvents(gameObject="Self", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`

2. `ActivateGameObject(gameObject="Owner($Thwip Slash)", activate=1, recursive=0, resetOnExit=true, everyFrame=false)`



#### Death Pose · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:426522>)

出口：EVADE → Idle。isSequence=0。

1. `GetXDistance(gameObject="Self", target="$Hero", storeResult="$Distance", everyFrame=false)`

2. `FloatCompare(float1="$Distance", float2=2, tolerance=0, equal=null, lessThan="EVADE", greaterThan=null, everyFrame=false)`

3. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.0)`

4. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Laugh", animationTriggerEvent=null, animationCompleteEvent=null)`

5. `AudioPlayRandom(gameObject="$Self", audioClips=["GUID:a5835f30a55e98845b0fdd9d8fc76020#8300000"], weights=[1], pitchMin=1, pitchMax=1)`



#### Trap Stun · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:426733>)

出口：FINISHED → Idle。isSequence=0。

1. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Trap Stun")`

2. `SetVelocity2d(gameObject="Self", vector="None", x=0, y="None", everyFrame=false)`



#### Collide Cancel · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:426852>)

出口：FINISHED → RapidSlash Loop。isSequence=0。

1. `Tk2dWatchAnimationEvents(gameObject="Self", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`



#### Wait · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:426928>)

出口：FINISHED → Convo 1；CANCEL → Wait Shorter。isSequence=1。

1. `HeroTurnToFace(Target="Self")`

2. `Tk2dPlayAnimation(gameObject="Owner($Hero)", animLibName=null, clipName="Idle")`

3. `BoolTest(boolVariable="$Dormant Block", isTrue="CANCEL", isFalse=null, everyFrame=false)`

4. `Wait(time=2, finishEvent="FINISHED", realTime=false)`



#### Pause · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:427060>)

出口：FINISHED → Init。isSequence=0。

1. `NextFrameEvent(sendEvent="FINISHED")`



#### Location Check · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:427125>)

出口：DOCKS → Encountered?；GROTTO → Grotto Fight。isSequence=0。

1. `BoolTest(boolVariable="$Needolin Fight", isTrue="GROTTO", isFalse="DOCKS", everyFrame=false)`



#### Grotto Fight · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:427209>)

出口：MEET → Take Control New；REFIGHT → Grotto Refight。isSequence=0。

1. `FindAlertRange(target="Owner($Boss Scene)", storeResult="$Fight Range", childName="Fight Range")`

2. `SetFloatValue(floatVariable="$Land Y", floatValue=8.54, everyFrame=false)`

3. `SetFloatValue(floatVariable="$Centre X", floatValue=39.66, everyFrame=false)`

4. `PlayerDataBoolTest(boolName="encounteredLace1Grotto", isTrue="REFIGHT", isFalse="MEET")`



#### Take Control 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:427347>)

出口：LAND → Wait 2。isSequence=0。

1. `SetPlayerDataBool(boolName="disablePause", value=1)`

2. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Hero)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="FSM CANCEL", delay=0, everyFrame=false)`

3. `CallMethodProper(gameObject="Owner($Hero)", behaviour="HeroController", methodName="RelinquishControl", parameters=[], storeResult={"variableName":null,"objectType":"UnityEngine.Object","useVariable":1,"type":0,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}, EveryFrame=false)`

4. `SendMessage(gameObject="Owner($Hero)", delivery=0, options=1, functionCall={"FunctionName":"StartAnimationControlToIdle","parameterType":"None","BoolParameter":0,"FloatParameter":0,"IntParameter":0,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`

5. `SetVelocity2d(gameObject="Owner($Hero)", vector={"x":0,"y":0}, x="None", y="None", everyFrame=false)`

6. `GetPosition(gameObject="Owner($Hero)", vector="None", x="None", y="$Hero Y", z="None", space=0, everyFrame=true)`

7. `Wait(time=1, finishEvent="LAND", realTime=false)`

8. `FloatCompare(float1="$Hero Y", float2=8.65, tolerance=0, equal=null, lessThan="LAND", greaterThan=null, everyFrame=true)`



#### Wait 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:427780>)

出口：FINISHED → Met in Docks?。isSequence=1。

1. `HeroTurnToFace(Target="Self")`

2. `Tk2dPlayAnimation(gameObject="Owner($Hero)", animLibName=null, clipName="Idle")`

3. `Wait(time=0.5, finishEvent="FINISHED", realTime=false)`



#### Met in Docks? · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:427889>)

出口：MEET → Grotto Meet 1；REMEET → Grotto Remeet 1。isSequence=0。

1. `PlayerDataBoolTest(boolName="encounteredLace1", isTrue="REMEET", isFalse="MEET")`



#### Grotto Meet 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:427972>)

出口：CONVO_END → Grotto Meet 2。isSequence=0。

1. `RunDialogue(Sheet="Wanderers", Key="LACE_MEET_GROTTO_1", OverrideContinue=1, PlayerVoiceTableOverride="fileID:0", PreventHeroAnimation=0, HideDecorators=0, TextAlignment=0, OffsetY=0, Target="Self")`

2. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:18326e1ca471d7f489bf2967d888ebc2#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Grotto Meet 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:428161>)

出口：CONVO_END → Get Up Start。isSequence=0。

1. `RunDialogue(Sheet="Wanderers", Key="LACE_MEET_GROTTO_2", OverrideContinue=0, PlayerVoiceTableOverride="GUID:d0211822fbd355d4c872fb45b1c6d0c4#11400000", PreventHeroAnimation=0, HideDecorators=0, TextAlignment=0, OffsetY=0, Target="Self")`

2. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:483daa2893d30594791f0aa1d2604ff6#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

3. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="NPC Sit")`

4. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Silkflies)","fsmName":null,"sendToChildren":1,"fsmComponent":"fileID:0"}, sendEvent="LEAVE", delay=0, everyFrame=false)`



#### Grotto Meet 3 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:428425>)

出口：CONVO_END → End Dialogue。isSequence=0。

1. `FlipScale(gameObject="Self", flipHorizontally=true, flipVertically=false, everyFrame=false, lateUpdate=false)`

2. `SetIsKinematic2d(gameObject="Self", isKinematic=0)`

3. `SetPosition(gameObject="Self", vector="None", x="None", y="None", z=0.006, space=0, everyFrame=false, lateUpdate=false)`

4. `SetPlayerDataBool(boolName="encounteredLace1Grotto", value=1)`

5. `RunDialogue(Sheet="Wanderers", Key="LACE_MEET_GROTTO_3", OverrideContinue=0, PlayerVoiceTableOverride="fileID:0", PreventHeroAnimation=0, HideDecorators=0, TextAlignment=0, OffsetY=0, Target="Self")`

6. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:678914bbb7434984faf936c8f82a81e1#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

7. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:913122a8f5e67b949929bdc08043d936#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Grotto Remeet 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:428764>)

出口：CONVO_END → Grotto Remeet 2。isSequence=0。

1. `RunDialogue(Sheet="Wanderers", Key="LACE_REMEET_GROTTO_1", OverrideContinue=1, PlayerVoiceTableOverride="fileID:0", PreventHeroAnimation=0, HideDecorators=0, TextAlignment=0, OffsetY=0, Target="Self")`

2. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:18326e1ca471d7f489bf2967d888ebc2#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Grotto Remeet 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:428953>)

出口：CONVO_END → Get Up Start 2。isSequence=0。

1. `RunDialogue(Sheet="Wanderers", Key="LACE_REMEET_GROTTO_2", OverrideContinue=0, PlayerVoiceTableOverride="GUID:d0211822fbd355d4c872fb45b1c6d0c4#11400000", PreventHeroAnimation=0, HideDecorators=0, TextAlignment=0, OffsetY=0, Target="Self")`

2. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:483daa2893d30594791f0aa1d2604ff6#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

3. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="NPC Sit")`

4. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Silkflies)","fsmName":null,"sendToChildren":1,"fsmComponent":"fileID:0"}, sendEvent="LEAVE", delay=0, everyFrame=false)`



#### Grotto Remeet 3 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:429217>)

出口：CONVO_END → End Dialogue。isSequence=0。

1. `RunDialogue(Sheet="Wanderers", Key="LACE_REMEET_GROTTO_3", OverrideContinue=0, PlayerVoiceTableOverride="fileID:0", PreventHeroAnimation=0, HideDecorators=0, TextAlignment=0, OffsetY=0, Target="Self")`

2. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:913122a8f5e67b949929bdc08043d936#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

3. `FlipScale(gameObject="Self", flipHorizontally=true, flipVertically=false, everyFrame=false, lateUpdate=false)`

4. `SetIsKinematic2d(gameObject="Self", isKinematic=0)`

5. `SetPosition(gameObject="Self", vector="None", x="None", y="None", z=0.006, space=0, everyFrame=false, lateUpdate=false)`

6. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:678914bbb7434984faf936c8f82a81e1#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Range Out · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:429540>)

出口：RANGE IN → Range Return；BLOCKED HIT → Swish Block；WAIT → Swish Block。isSequence=0。

1. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Idle")`

3. `CheckAlertRange(alertRange="$Fight Range", storeResult="None", InRangeEvent="RANGE IN", InRangeDelay=0, OutOfRangeEvent=null, OutOfRangeDelay=0, everyFrame=true)`

4. `SetInvincible(target="Self", Invincible=1, InvincibleFromDirection=0, resetOnStateExit=false)`

5. `WaitRandom(timeMin=4, timeMax=8, finishEvent="WAIT", realTime=false)`

6. `PreventInvincibleEffect(target="Self", preventEffect=0)`



#### Pose Swish 3 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:429779>)

出口：FINISHED → Idle。isSequence=0。

1. `Tk2dWatchAnimationEvents(gameObject="Self", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`



#### Evade 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:429855>)

出口：FINISHED → Evade Recover 2。isSequence=0。

1. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

2. `SetVelocityByScale(gameObject="Self", speed=-30, ySpeed="None", everyFrame=false)`

3. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Evade", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`

4. `AudioPlayerOneShot(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClips=["GUID:5612842bd9c91d54ca36821974b6eeb9#8300000","GUID:9156961f29e23534aaf1cb3053337526#8300000","GUID:6d0241d0624997e48ad3c91b42bcb3d8#8300000","GUID:0a03f8b9434c4a9469fe976a81948350#8300000"], weights=[1,1,1,1], pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

5. `AudioPlayRandom(gameObject="$Self", audioClips=["GUID:d2f0567df30ee22479d39ac4239db549#8300000","GUID:2e854a848e1a7de4b9d4aa14c2657d5e#8300000","GUID:797c8d3bcc7af3e45bfda47c257c342c#8300000"], weights=[1,1,1], pitchMin=1, pitchMax=1)`



#### Evade Recover 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:430145>)

出口：FINISHED → Keep Evading?。isSequence=0。

1. `SetVelocity2d(gameObject="Self", vector="None", x=0, y="None", everyFrame=false)`

2. `Tk2dWatchAnimationEvents(gameObject="Self", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`



#### Range Return · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:430254>)

出口：FINISHED → CrossSlash?。isSequence=0。

1. `SetInvincible(target="Self", Invincible=0, InvincibleFromDirection=0, resetOnStateExit=false)`

2. `PreventInvincibleEffect(target="Self", preventEffect=1)`



#### Swish Block · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:430359>)

出口：FINISHED → Range Out。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Swish Block", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `AudioPlayRandom(gameObject="$Self", audioClips=["GUID:18326e1ca471d7f489bf2967d888ebc2#8300000","GUID:74bb195a54383bd4a8a898a864ace681#8300000","GUID:96a43b099041dd44186d45aa7bdb453d#8300000"], weights=[1,1,1], pitchMin=1, pitchMax=1)`



#### Keep Evading? · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:430496>)

出口：EVADE → Evade 2；FINISHED → Range Out。isSequence=0。

1. `CheckTargetDirection(gameObject="Self", target="$Hero", aboveEvent=null, belowEvent=null, rightEvent=null, leftEvent=null, aboveBool="None", belowBool="None", rightBool="$Hero Is Right", leftBool="None", selfOffsetX=0, selfOffsetY=0, reverseIfNegativeScale=false, everyFrame=false)`

2. `CheckXPosition(gameObject="Self", compareTo="$Centre X", compareToOffset=0, tolerance=0, equal=null, equalBool="None", lessThan=null, lessThanBool="None", greaterThan=null, greaterThanBool="$Lace Is Right", everyFrame=false, space=0, activeBool="None")`

3. `BoolTestMulti(boolVariables=["$Lace Is Right","$Hero Is Right"], boolStates=[1,1], trueEvent="EVADE", falseEvent=null, storeResult="None", everyFrame=false)`

4. `BoolTestMulti(boolVariables=["$Lace Is Right","$Hero Is Right"], boolStates=[0,0], trueEvent="EVADE", falseEvent="FINISHED", storeResult="None", everyFrame=false)`



#### Grotto Refight Setup · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:430796>)

出口：FINISHED → Dormant。isSequence=0。

1. `PlayerDataBoolTest(boolName="encounteredLace1Grotto", isTrue=null, isFalse="FINISHED")`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Idle")`

3. `SetIsKinematic2d(gameObject="Self", isKinematic=0)`

4. `Translate(gameObject="Self", vector="None", x="None", y="None", z=1, space=0, perSecond=false, everyFrame=false, lateUpdate=false, fixedUpdate=false)`

5. `SetPosition(gameObject="Self", vector="None", x="None", y="None", z=0.006, space=0, everyFrame=false, lateUpdate=false)`

6. `ActivateGameObject(gameObject="Owner($Silkflies)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

7. `SetScale(gameObject="Self", vector="None", x=-1, y="None", z="None", everyFrame=false, lateUpdate=false)`



#### Get Up Start · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:431067>)

出口：FINISHED → Grotto Meet 3。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="SitToIdle", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`

2. `AudioPlayerOneShot(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClips=["GUID:5612842bd9c91d54ca36821974b6eeb9#8300000"], weights=[1], pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

3. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:0a03f8b9434c4a9469fe976a81948350#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Get Up Start 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:431273>)

出口：FINISHED → Grotto Remeet 3。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="SitToIdle", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`

2. `AudioPlayerOneShot(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClips=["GUID:5612842bd9c91d54ca36821974b6eeb9#8300000"], weights=[1], pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

3. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:0a03f8b9434c4a9469fe976a81948350#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Grotto Refight · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:431479>)

出口：FINISHED → Start Battle。isSequence=0。



#### Bind Bell Damage · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:431540>)

出口：FINISHED → RapidSlash End。isSequence=0。

1. `DamageHeroDirectly(damager="Self", damageAmount=1, spikeHazard=false, sinkHazard=false)`



#### Sing Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:431621>)

出口：FINISHED → Sing。isSequence=0。

1. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Sing", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`

3. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="STUN CONTROL START", delay=0, everyFrame=false)`

4. `AudioStop(gameObject="Self", fadeTime=0)`



#### Sing · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:431808>)

出口：END → Sing End；SING DURATION END → Sing End。isSequence=0。

1. `EnemySingControl(enemyGameObject="Self", audioPlayer="$Self", singAudioTable="GUID:5b768a9d5abf7504b9af67635019e4bd#11400000", noThreadEffects=0, noPuppetString=1, randomSingStartTime=0, dontStopAudioOnExit=0, altThreadSpawnPoint="fileID:0")`

2. `CheckHeroPerformanceRegionV2(Target="Self", Radius=0, MinReactDelay=0.5, MaxReactDelay=0.5, None="END", ActiveInner=null, ActiveOuter=null, IgnoreNeedolinRange=1, UseActiveBool=0, ActiveBool="None", StoreState="None", EveryFrame=true)`



#### Sing End · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:432007>)

出口：FINISHED → Will Counter?。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Sing End", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`



#### Convo 3 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:432090>)

出口：CONVO_END → Turn To Idle。isSequence=0。

1. `RunDialogue(Sheet="Wanderers", Key="LACE_MEET_3", OverrideContinue=0, PlayerVoiceTableOverride="GUID:d0211822fbd355d4c872fb45b1c6d0c4#11400000", PreventHeroAnimation=1, HideDecorators=0, TextAlignment=0, OffsetY=0, Target="Self")`

2. `CallMethodProper(gameObject="Owner($Hero)", behaviour="HeroController", methodName="StopAnimationControl", parameters=[], storeResult={"variableName":null,"objectType":"UnityEngine.Object","useVariable":1,"type":-1,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}, EveryFrame=false)`

3. `Tk2dPlayAnimation(gameObject="Owner($Hero)", animLibName=null, clipName="Challenge Talk Start")`

4. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Hero", audioClip="GUID:248956da6d26451478ac8ace8316ef5a#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0.25, storePlayer="fileID:0")`

5. `PlayAudioEvent(audioClip="GUID:a359498bf0fa26c4b860e7bb448ff191#8300000", pitchMin=1, pitchMax=1, volume=1, audioPlayerPrefab="None", spawnPoint="Self", spawnPosition={"x":0,"y":0,"z":0}, SpawnedPlayerRef="None")`



#### End Dialogue 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:432419>)

出口：FINISHED → Start Battle。isSequence=0。

1. `SetPlayerDataBool(boolName="disablePause", value=0)`

2. `EndDialogue(ReturnControl=1, ReturnHUD=1, Target="Self", UseChildren=0)`

3. `CallMethodProper(gameObject="Owner($Hero)", behaviour="HeroController", methodName="RegainControl", parameters=[], storeResult={"variableName":null,"objectType":"UnityEngine.Object","useVariable":1,"type":-1,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}, EveryFrame=false)`

4. `CallMethodProper(gameObject="Owner($Hero)", behaviour="HeroController", methodName="StartAnimationControl", parameters=[], storeResult={"variableName":null,"objectType":"UnityEngine.Object","useVariable":1,"type":-1,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}, EveryFrame=false)`



#### Dormant Block · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:432634>)

出口：BLOCKED HIT → Dormant Block；FINISHED → Dormant Blocked Idle；ENTER → Location Check 2。isSequence=0。

1. `CreateNoise(From="Self", LocalOrigin={"x":0,"y":0}, Radius=6)`

2. `SpawnObjectFromGlobalPool(gameObject="GUID:66beb3d2b1f4de34cbd28a947448fd8a#1709254077376921", spawnPoint="$Self", position="None", rotation="None", storeObject="$Effect")`

3. `PlayAudioEvent(audioClip="GUID:9eb895b41b5e19a4a835cbd03a861dfb#8300000", pitchMin=0.85, pitchMax=1.15, volume=1, audioPlayerPrefab="None", spawnPoint="Self", spawnPosition={"x":0,"y":0,"z":0}, SpawnedPlayerRef="None")`

4. `SetRandomRotation(gameObject="Owner($Effect)", x="None", y="None", z=1)`

5. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

6. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Swish Block Long", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

7. `ActivateGameObject(gameObject="Owner($Attack Detector)", activate=1, recursive=0, resetOnExit=true, everyFrame=false)`

8. `ReceivedDamage(Target="Owner($Attack Detector)", collideTag="None", sendEvent="BLOCKED HIT", sendEventHeavy=null, sendEventSpikes=null, sendEventLava=null, sendEventLightning=null, storeGameObject="None", ignoreAcid=0, ignoreLava=0, ignoreWater=0, ignoreHunterWeapon=0, ignoreTraps=0, ignoreNail=0, ignoreSpikes=0, storeDamageDealt="None", storeDirection="None", storeMagnitudeMultiplier="None", firstHitOnly=0)`



#### Block Voice · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:433066>)

出口：FINISHED → Dormant Block。isSequence=0。

1. `SetBoolValue(boolVariable="$NPC Blocked Hit", boolValue=1, everyFrame=false)`

2. `AudioPlayRandomVoice(gameObject="Owner($Audio Loop Voice)", audioClips=["GUID:9a2635be9d2e49843ad97ba5c564d576#8300000","GUID:74bb195a54383bd4a8a898a864ace681#8300000","GUID:913122a8f5e67b949929bdc08043d936#8300000"], weights=[1,1,1], pitchMin=1, pitchMax=1, stopPreviousSound=true)`

3. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Silkflies)","fsmName":null,"sendToChildren":1,"fsmComponent":"fileID:0"}, sendEvent="LEAVE", delay=0, everyFrame=false)`



#### Dormant Blocked Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:433251>)

出口：BLOCKED HIT → Dormant Block；ENTER → Scene Start。isSequence=0。

1. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Idle")`

2. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:678914bbb7434984faf936c8f82a81e1#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

3. `ActivateGameObject(gameObject="Owner($Attack Detector)", activate=1, recursive=0, resetOnExit=true, everyFrame=false)`

4. `ReceivedDamage(Target="Owner($Attack Detector)", collideTag="None", sendEvent="BLOCKED HIT", sendEventHeavy=null, sendEventSpikes=null, sendEventLava=null, sendEventLightning=null, storeGameObject="None", ignoreAcid=0, ignoreLava=0, ignoreWater=0, ignoreHunterWeapon=0, ignoreTraps=0, ignoreNail=0, ignoreSpikes=0, storeDamageDealt="None", storeDirection="None", storeMagnitudeMultiplier="None", firstHitOnly=0)`



#### Conduct End · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:433544>)

出口：FINISHED → Convo 2。isSequence=0。

1. `BoolTest(boolVariable="$NPC Blocked Hit", isTrue="FINISHED", isFalse=null, everyFrame=false)`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Conduct End")`

3. `AudioPlayRandomVoiceFromTable(gameObject="Self", audioClipTable="GUID:7e4a21cd4cc147c4084b1a0bc7f1a1bd#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`



#### Turn To Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:433666>)

出口：FINISHED → Convo 4。isSequence=0。

1. `BoolTest(boolVariable="$NPC Blocked Hit", isTrue="FINISHED", isFalse=null, everyFrame=false)`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="TurnToIdle")`

3. `SetScale(gameObject="Self", vector="None", x=-1, y="None", z="None", everyFrame=false, lateUpdate=false)`

4. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:678914bbb7434984faf936c8f82a81e1#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Take Control New · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:433866>)

出口：FINISHED → Wait 2。isSequence=0。

1. `BoolTest(boolVariable="$Dormant Block", isTrue="FINISHED", isFalse=null, everyFrame=false)`

2. `RunFSM(fsmTemplateControl={"targetType":0,"target":"GUID:6acb65dd9070fec409d4a74210794792#11400000","inputVariables":[{"variable":"$Clamp X","fsmVar":{"variableName":null,"objectType":"UnityEngine.Object","useVariable":0,"type":0,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}},"isEdited":0}],"outputVariables":[],"outputEvents":[]}, finishEvent="FINISHED", everyFrame=false)`



#### To Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:433984>)

出口：FINISHED → Scene Start。isSequence=0。

1. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:678914bbb7434984faf936c8f82a81e1#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Idle")`



#### Capture Hero · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:434129>)

出口：FINISHED → Hero Turn。isSequence=0。

1. `SetBoolValue(boolVariable="$Dormant Block", boolValue=1, everyFrame=false)`

2. `TransitionToAudioSnapshot(snapshot="GUID:1e5b83863824c3e46b1a27345f960db5#24500034", transitionTime=6)`

3. `PlayerDataBoolTest(boolName="encounteredLace1", isTrue="FINISHED", isFalse=null)`

4. `SetPlayerDataBool(boolName="disablePause", value=1)`

5. `SetPlayerDataBool(boolName="isInvincible", value=1)`

6. `RunFSM(fsmTemplateControl={"targetType":0,"target":"GUID:6acb65dd9070fec409d4a74210794792#11400000","inputVariables":[{"variable":"$Clamp X","fsmVar":{"variableName":null,"objectType":"UnityEngine.Object","useVariable":0,"type":0,"floatValue":92.75,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}},"isEdited":0}],"outputVariables":[],"outputEvents":[]}, finishEvent=null, everyFrame=false)`



#### Location Check 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:434312>)

出口：DOCKS → Capture Hero；GROTTO → Capture Hero 2。isSequence=0。

1. `BoolTest(boolVariable="$Needolin Fight", isTrue="GROTTO", isFalse="DOCKS", everyFrame=false)`



#### Capture Hero 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:434396>)

出口：FINISHED → Hero Turn。isSequence=0。

1. `SetBoolValue(boolVariable="$Dormant Block", boolValue=1, everyFrame=false)`

2. `TransitionToAudioSnapshot(snapshot="GUID:1e5b83863824c3e46b1a27345f960db5#24500034", transitionTime=6)`

3. `SetPlayerDataBool(boolName="disablePause", value=1)`

4. `SetPlayerDataBool(boolName="isInvincible", value=1)`

5. `RunFSM(fsmTemplateControl={"targetType":0,"target":"GUID:6acb65dd9070fec409d4a74210794792#11400000","inputVariables":[{"variable":"$Clamp X","fsmVar":{"variableName":null,"objectType":"UnityEngine.Object","useVariable":0,"type":0,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}},"isEdited":0}],"outputVariables":[],"outputEvents":[]}, finishEvent=null, everyFrame=false)`



#### Wait Shorter · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:434566>)

出口：FINISHED → Convo 1。isSequence=0。

1. `Wait(time=1, finishEvent=null, realTime=false)`



#### Hero Turn · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:434639>)

出口：FINISHED → Wait Lace Anim。isSequence=1。

1. `PlayerDataBoolTest(boolName="encounteredLace1", isTrue="FINISHED", isFalse=null)`

2. `HeroTurnToFace(Target="Self")`

3. `Tk2dPlayAnimation(gameObject="Owner($Hero)", animLibName=null, clipName="Idle")`



#### Wait Lace Anim · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:434749>)

出口：FINISHED → To Idle。isSequence=0。

1. `Tk2dWatchAnimationEvents(gameObject="Self", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `Wait(time=0.5, finishEvent="FINISHED", realTime=false)`



#### Lava Damage · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:434837>)

出口：FINISHED → Lava Hop。isSequence=0。

1. `SetVelocity2d(gameObject="Self", vector={"x":0,"y":0}, x="None", y="None", everyFrame=false)`

2. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="STUN CONTROL STOP", delay=0, everyFrame=false)`

3. `SubtractHP(target="Self", amount=40)`

4. `FreezeMoment(FreezeMomentType=1)`

5. `PlayAudioEvent(audioClip="GUID:355ab94ffb2f4b14f8f63d140df84772#8300000", pitchMin=1, pitchMax=1, volume=1, audioPlayerPrefab="None", spawnPoint="Self", spawnPosition={"x":0,"y":0,"z":0}, SpawnedPlayerRef="None")`

6. `SpawnObjectFromGlobalPool(gameObject="GUID:e8cc2e9b30dec42429a0f3f6518e2e2f#1709254077376921", spawnPoint="$Self", position="None", rotation="None", storeObject="None")`

7. `GetFsmFloat(gameObject="Self", fsmName="Detect Lava Damage", variableName="Lava Pos Y", storeValue="$Lava Pos Y", everyFrame=false)`

8. `FloatAdd(floatVariable="$Lava Pos Y", add=0.2, everyFrame=false, perSecond=false)`

9. `GetPosition2d(gameObject="Self", vector_2d="None", x="$Self X", y="None", space=0, everyFrame=false)`

10. `FloatClamp(floatVariable="$Self X", minValue=79, maxValue=109, everyFrame=false)`

11. `SetPosition2d(gameObject="Self", vector="None", x="$Self X", y="$Lava Pos Y", space=1, everyFrame=false, lateUpdate=false)`

12. `PlayRandomAudioClipTable(Table="GUID:787f8474d781c7b43a06b9f447d92919#11400000", AudioPlayerPrefab="None", SpawnPoint="Self", SpawnPosition={"x":0,"y":0,"z":0})`

13. `SetGravity2dScale(gameObject="Self", gravityScale=0)`

14. `Wait(time=0.85, finishEvent="FINISHED", realTime=false)`

15. `SetRecoilBlocked(Target="Self", IsUpBlocked=1, IsDownBlocked=1, IsLeftBlocked=1, IsRightBlocked=1)`

16. `FaceObjectV2(objectA="Self", objectB="$Arena Centre", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

17. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Death Air")`

18. `ObjectJitterOnRender(Target="Self", X=0.05, Y=0.05, Z="None", LimitFps=30)`

19. `SetSpecialDeath(target="Self", hasSpecialDeath=1)`



#### Lava Hop · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:435473>)

出口：FINISHED → Lava Tele Out。isSequence=0。

1. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Fall")`

2. `SetVelocity2d(gameObject="Self", vector="None", x="None", y=80, everyFrame=false)`

3. `SetDamageHeroAmount(target="Self", damageDealt=1)`

4. `DecelerateXY(gameObject="Self", decelerationX="None", decelerationY=0.85, brakeOnExit=false)`

5. `Wait(time=0.4, finishEvent="FINISHED", realTime=false)`

6. `SpawnObjectFromGlobalPool(gameObject="GUID:e17f0f93ccf55bd459b603e5af965eb6#1709254077376921", spawnPoint="$Self", position={"x":0,"y":2,"z":0}, rotation="None", storeObject="None")`

7. `PlayAudioEvent(audioClip="GUID:f5ae1bc4615b9fa4e8a2c5616fa94ec3#8300000", pitchMin=1, pitchMax=1, volume=1, audioPlayerPrefab="None", spawnPoint="Self", spawnPosition={"x":0,"y":0,"z":0}, SpawnedPlayerRef="None")`

8. `PlayAudioEvent(audioClip="GUID:4d52a8fbdf1758c4fa274b3273d9bb02#8300000", pitchMin=1, pitchMax=1, volume=1, audioPlayerPrefab="None", spawnPoint="Self", spawnPosition={"x":0,"y":0,"z":0}, SpawnedPlayerRef="None")`



#### Lava Tele Out · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:435809>)

出口：FINISHED → Set Tele Pos X。isSequence=0。

1. `PlayRandomAudioClipTable(Table="GUID:1654501e0469aa84f9de1ab724d0146e#11400000", AudioPlayerPrefab="None", SpawnPoint="Self", SpawnPosition={"x":0,"y":0,"z":0})`

2. `SetVelocity2d(gameObject="Self", vector={"x":0,"y":0}, x="None", y="None", everyFrame=false)`

3. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Tele Out", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`



#### Set Tele Pos X · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:435959>)

出口：FINISHED → Tele In。isSequence=0。

1. `SetPosition2d(gameObject="Self", vector="None", x="$Centre X", y="$Land Y", space=1, everyFrame=false, lateUpdate=false)`

2. `GetXDistance(gameObject="Owner($Hero)", target="$Arena Centre", storeResult="$Distance", everyFrame=false)`

3. `FloatCompare(float1="$Distance", float2=3, tolerance=0, equal=null, lessThan=null, greaterThan="FINISHED", everyFrame=false)`

4. `GetScale(gameObject="Self", vector="None", xScale="$X Scale", yScale="None", zScale="None", space=0, everyFrame=false)`

5. `FloatMultiply(floatVariable="$X Scale", multiplyBy=8, everyFrame=false)`

6. `Translate(gameObject="Self", vector="None", x="$X Scale", y="None", z="None", space=0, perSecond=false, everyFrame=false, lateUpdate=false, fixedUpdate=false)`



#### Tele In · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:436213>)

出口：FINISHED → Lava End。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Tele In Fast", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`



#### Lava End · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:436296>)

出口：FINISHED → Idle。isSequence=0。

1. `SetGravity2dScale(gameObject="Self", gravityScale="$Gravity")`

2. `SendMessage(gameObject="Self", delivery=0, options=0, functionCall={"FunctionName":"StartConstrainX","parameterType":"None","BoolParameter":0,"FloatParameter":0,"IntParameter":0,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`

3. `SendMessage(gameObject="Self", delivery=0, options=0, functionCall={"FunctionName":"StartConstrainY","parameterType":"None","BoolParameter":0,"FloatParameter":0,"IntParameter":0,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`

4. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="STUN CONTROL START", delay=0, everyFrame=false)`

5. `SetRecoilBlocked(Target="Self", IsUpBlocked=0, IsDownBlocked=0, IsLeftBlocked=0, IsRightBlocked=0)`

6. `SetSpecialDeath(target="Self", hasSpecialDeath=0)`

7. `SetDamageHeroAmount(target="Self", damageDealt=1)`



#### Wallcling · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:436774>)

出口：FINISHED → Kickoff。isSequence=0。

1. `PlayAudioEvent(audioClip="GUID:d984bf7e6bf79534bab3c1b8242151a8#8300000", pitchMin=1.2, pitchMax=1.2, volume=1, audioPlayerPrefab="None", spawnPoint="Self", spawnPosition={"x":0,"y":0,"z":0}, SpawnedPlayerRef="None")`

2. `SetGravity2dScale(gameObject="Self", gravityScale=0)`

3. `SetVelocityByScale(gameObject="Self", speed=30, ySpeed=0, everyFrame=false)`

4. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Wall Bounce", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`



#### Dstab Constrain? · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:436963>)

出口：FINISHED → Downstab Antic。isSequence=0。

1. `GetPosition2d(gameObject="Self", vector_2d="None", x="$Self X", y="None", space=0, everyFrame=false)`

2. `FloatInRange(floatVariable="$Self X", lowerValue=86, upperValue=102, boolVariable="None", trueEvent=null, falseEvent="FINISHED", everyFrame=false)`

3. `SendMessage(gameObject="Self", delivery=0, options=0, functionCall={"FunctionName":"StartConstrainX","parameterType":"None","BoolParameter":0,"FloatParameter":0,"IntParameter":0,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`

4. `SendMessage(gameObject="Self", delivery=0, options=0, functionCall={"FunctionName":"StartConstrainY","parameterType":"None","BoolParameter":0,"FloatParameter":0,"IntParameter":0,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`



#### Kickoff · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:437367>)

出口：FINISHED → J Slash 1。isSequence=0。

1. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

2. `GetXDistance(gameObject="Self", target="$Hero", storeResult="$Distance", everyFrame=false)`

3. `FloatCompare(float1="$Distance", float2=2, tolerance=0, equal=null, lessThan=null, greaterThan="FINISHED", everyFrame=false)`

4. `FaceObjectV2(objectA="Self", objectB="$Arena Centre", spriteFacesRight=0, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`



#### Use Wall Range? · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:437556>)

出口：FINISHED → Grotto Refight Setup。isSequence=0。

1. `PlayerDataBoolTest(boolName="hasWalljump", isTrue="FINISHED", isFalse=null)`

2. `FindChild(gameObject="Owner($Boss Scene)", childName="Wall Range", storeResult="$Wall Range Obj")`

3. `SetPosition2d(gameObject="Owner($Wall Range Obj)", vector="None", x="None", y=500, space=0, everyFrame=false, lateUpdate=false)`



### Cross Slash / Multihit [fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:443052>)

变量初值：`{"boolVariables":{"Bind Bell Hit":0},"gameObjectVariables":{"Audio Player":{"fileID":0},"Hornet Hit":{"fileID":0},"Parent":{"fileID":0},"Self":{"fileID":0},"Lace":{"fileID":0}}}`

全局迁移：`[]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:443069>)

出口：FINISHED → Idle。isSequence=0。

1. `GetOwner(storeGameObject="$Self")`

2. `GetParent(gameObject="Self", storeResult="$Parent")`

3. `FindChild(gameObject="Self", childName="Hornet Hit", storeResult="$Hornet Hit")`

4. `ActivateGameObject(gameObject="Owner($Hornet Hit)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`



#### Attacking · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:443209>)

出口：MULTIHIT → Register Hit。isSequence=0。

1. `AudioPlayerOneShotSingle(audioPlayer="GUID:e8466d04a5c03bc4b8d6a0838af84de7#1709254077376921", spawnPoint="$Self", audioClip="GUID:b9c06e3d42740da4e835c05cb2a562be#8300000", pitchMin=1, pitchMax=1, volume=0, delay=0, storePlayer="$Audio Player")`



#### Register Hit · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:443329>)

出口：BIND BELL → Bind Bell Damage。isSequence=0。

1. `CallMethodProper(gameObject="Owner($Hero)", behaviour="HeroController", methodName="WillDoBellBindHit", parameters=[], storeResult={"variableName":"Bind Bell Hit","objectType":"UnityEngine.Object","useVariable":1,"type":2,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}, EveryFrame=false)`

2. `BoolTest(boolVariable="$Bind Bell Hit", isTrue="BIND BELL", isFalse=null, everyFrame=false)`

3. `ActivateGameObject(gameObject="Owner($Hornet Hit)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

4. `ScreenFlash(flashColour={"r":1,"g":1,"b":1,"a":0.528})`

5. `SetVelocity2d(gameObject="Owner($Hero)", vector={"x":0,"y":0}, x="None", y="None", everyFrame=true)`

6. `SetPositionToObject(gameObject="Owner($Hero)", targetObject="$Self", xOffset=0, yOffset=0, zOffset=0, overrideZ="None", everyFrame=false)`

7. `SetMeshRenderer(gameObject="Owner($Hero)", active=0)`

8. `SetFsmBool(gameObject="Owner($Parent)", fsmName="Control", variableName="CrossSlashing Hero", setValue=1, everyFrame=false)`

9. `DoCameraShake(VisibleRenderer="Self", Camera="GUID:9b0888e0916dca544846a2f34304dac9#11400000", Profile="GUID:e483858fc9bec004c905f955c1162848#11400000", cancelOnExit=false, DoFreeze=1, Delay=0)`

10. `DoCameraShake(VisibleRenderer="Self", Camera="GUID:9b0888e0916dca544846a2f34304dac9#11400000", Profile="GUID:f9ce329e054eb6049abb444b14a1c899#11400000", cancelOnExit=false, DoFreeze=1, Delay=0)`

11. `FadeAudio(gameObject="Owner($Audio Player)", startVolume=0, endVolume=1, time=0.1)`



#### Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:443740>)

出口：ATTACK START → Attacking；MULTIHIT → Register Hit。isSequence=0。



#### Bind Bell Damage · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:443810>)

出口：FINISHED → Idle。isSequence=0。

1. `DamageHeroDirectly(damager="Self", damageAmount=1, spikeHazard=false, sinkHazard=false)`



### hero damager / Multihitter [fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:444724>)

变量初值：`{"boolVariables":{"Bind Bell Hit":0,"Parrying":0},"gameObjectVariables":{"Lace":{"fileID":0}}}`

全局迁移：`[]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:444741>)

出口：FINISHED → Idle。isSequence=0。

1. `GetParent(gameObject="Self", storeResult="$Lace")`



#### Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:444820>)

出口：TRIGGER STAY 2D → Start Hit?。isSequence=0。



#### Hit · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:444881>)

出口：MULTIHIT END → Idle。isSequence=0。

1. `CallMethodProper(gameObject="Owner($Hero)", behaviour="HeroController", methodName="TakeQuickDamage", parameters=[{"variableName":null,"objectType":null,"useVariable":0,"type":1,"floatValue":0,"intValue":1,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}},{"variableName":null,"objectType":null,"useVariable":0,"type":2,"floatValue":0,"intValue":0,"boolValue":1,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}], storeResult={"variableName":null,"objectType":null,"useVariable":1,"type":-1,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}, EveryFrame=false)`

2. `SendEventToRegister(eventName="HERO DAMAGED")`

3. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Hero)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="WOUND START", delay=0, everyFrame=false)`

4. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Lace)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="MULTIHIT", delay=0, everyFrame=false)`



#### Start Hit? · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:445154>)

出口：CANCEL → None；HIT → Hit；BIND BELL → Bind Bell Damage；CROSS STITCH → Cross Stitch。isSequence=0。

1. `GetHeroCState(VariableName="parrying", StoreValue="$Parrying", EveryFrame=false)`

2. `BoolTest(boolVariable="$Parrying", isTrue="CROSS STITCH", isFalse=null, everyFrame=false)`

3. `CallMethodProper(gameObject="Owner($Hero)", behaviour="HeroController", methodName="WillDoBellBindHit", parameters=[], storeResult={"variableName":"Bind Bell Hit","objectType":"UnityEngine.Object","useVariable":1,"type":2,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}, EveryFrame=false)`

4. `BoolTest(boolVariable="$Bind Bell Hit", isTrue="BIND BELL", isFalse=null, everyFrame=false)`

5. `CanHeroTakeDamage(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, canTakeDmgEvent="HIT", cannotTakeDmgEvent="CANCEL")`



#### Bind Bell Damage · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:445379>)

出口：FINISHED → Idle。isSequence=0。

1. `DamageHeroDirectly(damager="Self", damageAmount=1, spikeHazard=false, sinkHazard=false)`



#### Cross Stitch · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:445460>)

出口：FINISHED → Idle。isSequence=0。

1. `Wait(time=0.5, finishEvent="FINISHED", realTime=false)`

2. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Hero)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="PARRIED", delay=0, everyFrame=false)`



### Lace Boss1 / Check Death [fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:446486>)

变量初值：`{}`

全局迁移：`[]`

#### State 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:446503>)

出口：HORNET DEATH → State 2。isSequence=0。



#### State 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:446564>)

出口：无本地迁移（持续/外部驱动）。isSequence=0。

1. `SetFsmBool(gameObject="Self", fsmName="Control", variableName="Hornet Dead", setValue=1, everyFrame=false)`



### Lace Boss1 / Stun Control [fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:451109>)

变量初值：`{"floatVariables":{"Combo Time":1,"Daze X Scale":0,"Daze Y Scale":0,"Hits Total":0,"Combo Counter":0,"Stun Damage":0,"Epsilon":0.01},"intVariables":{"Stun Combo":8,"Stun Hit Max":10},"boolVariables":{"Daze Effect Active":0,"Abyss Attacking":0},"gameObjectVariables":{"DazedEffect":{"fileID":0},"DazedEffect Marker":{"fileID":0},"Self":{"fileID":0}}}`

全局迁移：`[{"fsmEvent":{"name":"STUN CONTROL FORCE STUN","isSystemEvent":0,"isGlobal":0},"toState":"Stun","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0},{"fsmEvent":{"name":"STUN CONTROL STOP","isSystemEvent":0,"isGlobal":0},"toState":"Stop Daze Effect 2","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0},{"fsmEvent":{"name":"STUN CONTROL RESET","isSystemEvent":0,"isGlobal":0},"toState":"Stop Daze Effect 3","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0}]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:451126>)

出口：FINISHED → Idle。isSequence=0。

1. `GetOwner(storeGameObject="$Self")`

2. `FindChild(gameObject="Self", childName="DazedEffect Marker", storeResult="$DazedEffect Marker")`



#### Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:451221>)

出口：STUN DAMAGE → Max Check。isSequence=0。

1. `SetFloatValue(floatVariable="$Stun Damage", floatValue=0.0, everyFrame=false)`



#### In Combo · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:451287>)

出口：TIME OUT → Reset Counter；STUN DAMAGE → Continue Combo；STUN → Stun。isSequence=0。

1. `FloatAdd(floatVariable="$Combo Counter", add="$Stun Damage", everyFrame=false, perSecond=false)`

2. `FloatAdd(floatVariable="$Hits Total", add="$Stun Damage", everyFrame=false, perSecond=false)`

3. `SetFloatValue(floatVariable="$Stun Damage", floatValue=0.0, everyFrame=false)`

4. **disabled** `FloatCompare(float1="$Combo Counter", float2="$Stun Combo", tolerance="$Epsilon", equal="STUN", lessThan=null, greaterThan="STUN", everyFrame=false)`

5. `Wait(time="$Combo Time", finishEvent="TIME OUT", realTime=false)`



#### Reset Counter · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:451397>)

出口：FINISHED → Stop Daze Effect。isSequence=0。

1. `SetFloatValue(floatVariable="$Combo Counter", floatValue=0.0, everyFrame=false)`



#### Continue Combo · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:451463>)

出口：FINISHED → In Combo；STUN → Stun。isSequence=0。

1. `BoolTest(boolVariable="$Abyss Attacking", isTrue="FINISHED", isFalse=null, everyFrame=false)`

2. `FloatCompare(float1="$Hits Total", float2="$Stun Hit Max", tolerance="$Epsilon", equal="STUN", lessThan=null, greaterThan="STUN", everyFrame=false)`



#### Stun · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:451548>)

出口：FINISHED → Dazed Effect。isSequence=0。

1. `SpawnObjectFromGlobalPool(gameObject="GUID:5283cc506c688be448065d0227ce1390#1709254077376921", spawnPoint="$Self", position="None", rotation="None", storeObject="None")`

2. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="STUN", delay=0.0, everyFrame=false)`

3. `SetFloatValue(floatVariable="$Combo Counter", floatValue=0.0, everyFrame=false)`

4. `SetFloatValue(floatVariable="$Hits Total", floatValue=0.0, everyFrame=false)`

5. `SendMessage(gameObject="Self", delivery=0, options=1, functionCall={"FunctionName":"ResetSingCooldown","parameterType":"None","BoolParameter":0,"FloatParameter":0,"IntParameter":0,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`



#### Max Check · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:451825>)

出口：FINISHED → In Combo；STUN → Stun。isSequence=0。

1. `BoolTest(boolVariable="$Abyss Attacking", isTrue="FINISHED", isFalse=null, everyFrame=false)`

2. `FloatCompare(float1="$Hits Total", float2="$Stun Hit Max", tolerance="$Epsilon", equal="STUN", lessThan="FINISHED", greaterThan="STUN", everyFrame=false)`



#### Stop · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:451910>)

出口：STUN CONTROL START → Reset Counter；STUN DAMAGE → Unstun Increment。isSequence=0。



#### Unstun Increment · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:451980>)

出口：FINISHED → Stop。isSequence=0。

1. `FloatAdd(floatVariable="$Hits Total", add="$Stun Damage", everyFrame=false, perSecond=false)`

2. `SetFloatValue(floatVariable="$Stun Damage", floatValue=0.0, everyFrame=false)`



#### Reset · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:452052>)

出口：STUN CONTROL START → Reset Counter。isSequence=0。

1. `SetFloatValue(floatVariable="$Hits Total", floatValue=0.0, everyFrame=false)`



#### Dazed Effect · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:452118>)

出口：FINISHED → Stunned。isSequence=0。

1. `GameObjectIsNull(gameObject="$DazedEffect Marker", isNull="FINISHED", isNotNull=null, storeResult="None", everyFrame=false)`

2. `GetScale(gameObject="Owner($DazedEffect Marker)", vector="None", xScale="$Daze X Scale", yScale="$Daze Y Scale", zScale="None", space=0, everyFrame=false)`

3. `SpawnObjectFromGlobalPool(gameObject="GUID:da2b82da172005b4cb576be2afe73009#1709254077376921", spawnPoint="$DazedEffect Marker", position="None", rotation="None", storeObject="$DazedEffect")`

4. `SetScale(gameObject="Owner($DazedEffect)", vector="None", x="$Daze X Scale", y="$Daze Y Scale", z="None", everyFrame=false, lateUpdate=false)`

5. **disabled** `Tk2dPlayAnimation(gameObject="Owner($DazedEffect)", animLibName=null, clipName="Dazed")`

6. `SetParent(gameObject="Owner($DazedEffect)", parent="$Self", resetLocalPosition=false, resetLocalRotation=false)`



#### Stun End · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:452296>)

出口：FINISHED → Stop Daze Effect。isSequence=0。

1. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:b1c29b3804a260f4d83275f93b80ade4#8300000", pitchMin=1.0, pitchMax=1.0, volume=1.0, delay=0.0, storePlayer="fileID:0")`



#### Stunned · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:452392>)

出口：STUN CONTROL START → Stun End；TOOK HEAVY DAMAGE → Quick End。isSequence=0。



#### Quick End · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:452462>)

出口：FINISHED → Stunned；STUN CONTROL START → Stun End。isSequence=0。

1. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="END", delay=0.0, everyFrame=false)`



#### Stop Daze Effect · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:452576>)

出口：FINISHED → Idle。isSequence=0。

1. `GameObjectIsNull(gameObject="$DazedEffect", isNull="FINISHED", isNotNull=null, storeResult="None", everyFrame=false)`

2. **disabled** `Tk2dPlayAnimation(gameObject="Owner($DazedEffect)", animLibName=null, clipName="Dazed End")`

3. **disabled** `Tk2dPlayFrame(gameObject="Self", frame=0)`

4. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($DazedEffect)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="STUN EFFECT END", delay=0.0, everyFrame=false)`

5. `AudioStop(gameObject="Owner($DazedEffect)", fadeTime=0.0)`

6. `SetGameObject(variable="$DazedEffect", gameObject="fileID:0", everyFrame=false)`



#### Stop Daze Effect 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:452760>)

出口：FINISHED → Stop。isSequence=0。

1. `GameObjectIsNull(gameObject="$DazedEffect", isNull="FINISHED", isNotNull=null, storeResult="None", everyFrame=false)`

2. **disabled** `Tk2dPlayAnimation(gameObject="Owner($DazedEffect)", animLibName=null, clipName="Dazed End")`

3. **disabled** `Tk2dPlayFrame(gameObject="Self", frame=0)`

4. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($DazedEffect)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="STUN EFFECT END", delay=0.0, everyFrame=false)`

5. `AudioStop(gameObject="Owner($DazedEffect)", fadeTime=0.0)`

6. `SetGameObject(variable="$DazedEffect", gameObject="fileID:0", everyFrame=false)`



#### Stop Daze Effect 3 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:452944>)

出口：FINISHED → Reset。isSequence=0。

1. `GameObjectIsNull(gameObject="$DazedEffect", isNull="FINISHED", isNotNull=null, storeResult="None", everyFrame=false)`

2. **disabled** `Tk2dPlayAnimation(gameObject="Owner($DazedEffect)", animLibName=null, clipName="Dazed End")`

3. **disabled** `Tk2dPlayFrame(gameObject="Self", frame=0)`

4. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($DazedEffect)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="STUN EFFECT END", delay=0.0, everyFrame=false)`

5. `AudioStop(gameObject="Owner($DazedEffect)", fadeTime=0.0)`

6. `SetGameObject(variable="$DazedEffect", gameObject="fileID:0", everyFrame=false)`



### Lace Boss1 / Escape CamLock Control [fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:455997>)

变量初值：`{"gameObjectVariables":{"Boss Scene":{"fileID":0},"Battle Scene":{"fileID":0},"CamLock LaceEscapeL":{"fileID":0},"CamLock LaceEscapeR":{"fileID":0}}}`

全局迁移：`[]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:456014>)

出口：FINISHED → Mid。isSequence=0。

1. `GetParent(gameObject="Self", storeResult="$Boss Scene")`

2. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Battle Scene")`

3. `FindNamedChild(gameObject="Owner($Battle Scene)", storeResult="$CamLock LaceEscapeL")`

4. `FindNamedChild(gameObject="Owner($Battle Scene)", storeResult="$CamLock LaceEscapeR")`



#### Mid · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:456147>)

出口：ESCAPE L → Escape L；ESCAPE R → Escape R。isSequence=0。

1. `ActivateGameObject(gameObject="Owner($CamLock LaceEscapeL)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

2. `ActivateGameObject(gameObject="Owner($CamLock LaceEscapeR)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

3. `CheckXPosition(gameObject="Self", compareTo=81.3, compareToOffset=0, tolerance=0, equal=null, equalBool="None", lessThan="ESCAPE L", lessThanBool="None", greaterThan=null, greaterThanBool="None", everyFrame=true, space=1, activeBool="None")`

4. `CheckXPosition(gameObject="Self", compareTo=106.6, compareToOffset=0, tolerance=0, equal=null, equalBool="None", lessThan=null, lessThanBool="None", greaterThan="ESCAPE R", greaterThanBool="None", everyFrame=true, space=1, activeBool="None")`



#### Escape L · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:456407>)

出口：RETURN → Mid。isSequence=0。

1. `ActivateGameObject(gameObject="Owner($CamLock LaceEscapeL)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

2. `ActivateGameObject(gameObject="Owner($CamLock LaceEscapeR)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

3. `CheckXPosition(gameObject="Self", compareTo=81.3, compareToOffset=0, tolerance=0, equal=null, equalBool="None", lessThan=null, lessThanBool="None", greaterThan="RETURN", greaterThanBool="None", everyFrame=true, space=1, activeBool="None")`



#### Escape R · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:456590>)

出口：RETURN → Mid。isSequence=0。

1. `ActivateGameObject(gameObject="Owner($CamLock LaceEscapeL)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

2. `ActivateGameObject(gameObject="Owner($CamLock LaceEscapeR)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

3. `CheckXPosition(gameObject="Self", compareTo=106.6, compareToOffset=0, tolerance=0, equal=null, equalBool="None", lessThan="RETURN", lessThanBool="None", greaterThan=null, greaterThanBool="None", everyFrame=true, space=1, activeBool="None")`



### Lace Boss1 / Detect Lava Damage [fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:458620>)

变量初值：`{"floatVariables":{"Lava Pos Y":1}}`

全局迁移：`[]`

#### Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:458637>)

出口：LAVA → Send Event。isSequence=0。

1. **disabled** `ReceivedDamage(Target="Self", collideTag="None", sendEvent=null, sendEventHeavy=null, sendEventSpikes=null, sendEventLava="LAVA", sendEventLightning=null, storeGameObject="None", ignoreAcid=0, ignoreLava=0, ignoreWater=0, ignoreHunterWeapon=0, ignoreTraps=0, ignoreNail=0, ignoreSpikes=0, storeDamageDealt="None", storeDirection="None", storeMagnitudeMultiplier="None", firstHitOnly=0)`

2. `CheckYPosition(gameObject="Self", compareTo="$Lava Pos Y", compareToOffset=0, tolerance=0, equal=null, lessThan="LAVA", greaterThan=null, everyFrame=true, space=0, activeBool="None")`



#### Send Event · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:458857>)

出口：FINISHED → Idle。isSequence=0。

1. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="LAVA DAMAGE", delay=0, everyFrame=false)`



### 动画事件索引

[动画库](</Users/mars/workspace/SilksongUnity6/Assets/Animations/Hornet Enemies/Lace Anim.prefab:1>)

|Clip|帧数|fps|wrapMode|loopStart|触发索引0基/标称秒|
|---|---:|---:|---:|---:|---|

|Idle|7|12|1|1||

|Combo Slash|28|24|2|0|14/0.583333, 15/0.625, 20/0.833333, 21/0.875|

|Antic|6|12|2|0||

|Rising Slash|5|18|2|0|2/0.111111, 3/0.166667, 4/0.222222|

|Charge Antic|4|12|2|0||

|RapidSlash Charge|2|12|2|0||

|TurnToIdle|8|12|1|2||

|Counter Stance|2|12|2|0||

|Engarde|9|12|2|0||

|Evade|7|15|2|0|3/0.2|

|Forward Hop|6|15|2|0|2/0.133333, 4/0.266667|

|NPC Idle Right|6|12|0|0||

|NPC Idle Turn Left|8|12|1|2||

|NPC Idle Left|6|12|0|0||

|NPC Idle Turn Right|8|12|1|2||

|Possession|3|12|0|0||

|Stun|5|12|1|1||

|Charge|1|12|2|0||

|Charge Recover|2|12|2|0||

|Downstab Antic|6|12|2|0||

|Downstab|1|30|0|0||

|Downstab End|4|15|2|0||

|Counter Antic|2|12|2|0||

|Counter End|3|15|2|0||

|Counter Hit|3|12|2|0||

|RapidSlash End|4|15|2|0||

|RapidSlash Loop|2|18|0|0||

|RapidSlash Effect|4|20|0|0||

|Jump Antic|6|12|2|0||

|Conduct|7|12|0|0||

|CrossSlash Antic|3|12|2|0||

|Conduct End|8|12|1|2||

|Stun Air|2|12|2|0||

|Stun Recover|3|15|2|0||

|Jump AnticQ|4|12|2|0||

|Jump Away|3|20|2|0||

|Eye Flash|4|30|2|0||

|MultiHit Slash|5|12|2|0||

|Pose Lean|11|15|2|0||

|Pose Upright|11|15|2|0||

|Pose Swish|11|15|2|0|1/0.066667, 3/0.2, 10/0.666667|

|Dash Burst|4|20|2|0||

|AirDash Burst|4|20|2|0||

|Stun Hit|6|12|1|2||

|Trap Stun|1|12|2|0||

|Pose Hornet Defeated|3|12|2|0|1/0.083333, 2/0.166667|

|NPC Sit|9|12|1|1||

|Swish Block|4|15|2|0||

|ConductToIdle|6|12|0|0||

|NPC Sit Antic|2|12|2|0||

|NPC SitLook|4|12|0|0||

|SitToIdle|10|12|1|4|2/0.166667|

|Combo Slash Q|26|24|2|0|12/0.5, 13/0.541667, 18/0.75, 19/0.791667|

|Downstab Antic Q|5|15|2|0||

|Bomb Slash Antic|7|12|2|0|2/0.166667, 4/0.333333|

|Bomb Slash|7|18|2|0|2/0.111111, 4/0.222222, 6/0.333333|

|Fall|3|12|0|0||

|Land|4|12|2|0||

|Death 1|4|12|1|2||

|Death 2|4|12|2|0|2/0.166667|

|Lie|1|30|6|0||

|LieToWake|9|12|2|0||

|Combo Slash Triple|32|24|2|0|14/0.583333, 15/0.625, 20/0.833333, 21/0.875, 26/1.083333, 27/1.125|

|P2 Shift Old|18|12|2|0|1/0.083333, 8/0.666667|

|ChargeMulti Antic|5|15|1|3||

|ChargeMulti|6|18|0|0||

|ChargeMulti Recover|2|12|2|0||

|Rising Slash Multi|9|25|1|5|8/0.32|

|Roar|4|12|1|2|1/0.083333|

|Death Stagger|2|12|0|0||

|Laugh|5|12|1|2|2/0.166667|

|Tele In|7|20|2|0||

|Death Air|3|12|0|0||

|Death Land Stun|9|12|1|5||

|Tele Out|5|20|2|0||

|Wall Bounce|4|15|2|0||

|Charge Crossup|7|12|2|0||

|Quick Slash|10|24|2|0|2/0.083333, 3/0.125|

|RapidSlashAir TeleIn|10|24|2|0|3/0.125|

|RapidSlashAir|3|20|0|0||

|Sing|5|12|1|3|2/0.166667|

|Sing End|2|12|2|1||

|RapidSlashAir End|8|16|1|2|2/0.125|

|Tele Out Fast|1|20|2|0||

|Counter Antic Fast|2|18|2|0||

|MultiHit Slash Air|1|12|2|0||

|Multihit AirEnd|6|16|0|0||

|P2 Shift|18|12|2|0|1/0.083333, 8/0.666667|

|Mid Battle Roar|8|12|1|5|3/0.25|

|Counter Flash|4|30|2|0||

|RapidSlashAir End Q|6|16|0|0||

|Swish Block Long|9|15|2|0||

|Combo Strike 1|6|24|2|0||

|Combo Strike 2|4|24|2|0||

|Charge Strike|4|20|2|0||

|Downstab Strike|3|15|2|0||

|Downstab Followup|3|18|2|0||

|Forward Hop Intro|11|12|2|0|5/0.416667, 7/0.583333|

|None|0|30|0|0||

|Combo Slash LongAntic|30|24|2|0|16/0.666667, 17/0.708333, 22/0.916667, 23/0.958333|

|Forward Hop Slow|6|13|2|0|2/0.153846, 4/0.307692|

|Lava Damage|4|12|0|0||

|Tele In Fast|7|24|2|0||


### 物理、伤害与碰撞组件定位

#### Lace Boss1 [组件4035](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:68186>)

```yaml
Rigidbody2D:
  serializedVersion: 5
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1623}
  m_BodyType: 0
  m_Simulated: 1
  m_UseFullKinematicContacts: 0
  m_UseAutoMass: 0
  m_Mass: 1
  m_LinearDamping: 0
  m_AngularDamping: 0.05
  m_GravityScale: 2
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_Interpolate: 0
  m_SleepingMode: 0
  m_CollisionDetection: 1
  m_Constraints: 4
```

#### hero damager [组件4082](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:69455>)

```yaml
CircleCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1712}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_Radius: 4.91
```

#### Circle Slash 1 [组件4100](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:70286>)

```yaml
PolygonCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1588}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Points:
    m_Paths:
    - - {x: 1.658104, y: 1.310894}
      - {x: 1.0386658, y: 1.7805815}
      - {x: 0.32190704, y: -0.72492504}
      - {x: -1.2717514, y: -2.9645472}
      - {x: 0.6765213, y: -2.6743793}
      - {x: 1.976448, y: -1.306447}
      - {x: 2.215355, y: -0.022603035}
  m_UseDelaunayMesh: 0
```

#### Combo Slash 1 [组件4103](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:70442>)

```yaml
PolygonCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1760}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Points:
    m_Paths:
    - - {x: -1.2843018, y: 1.6402125}
      - {x: -1.8815613, y: 0.654686}
      - {x: 0.36286163, y: 0.12963676}
      - {x: 1.2888527, y: -1.1386948}
      - {x: 2.6049595, y: -0.7443619}
      - {x: 3.5335617, y: 0.09479761}
      - {x: 4.036236, y: 0.8327484}
      - {x: 3.6984215, y: 1.8314209}
      - {x: 2.33243, y: 2.5110703}
      - {x: 0.020849228, y: 2.3015213}
  m_UseDelaunayMesh: 0
```

#### Charge Hit [组件4104](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:70499>)

```yaml
PolygonCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1548}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Points:
    m_Paths:
    - - {x: 0.70788574, y: 0.111032486}
      - {x: 0.7475586, y: -1.4197831}
      - {x: 2.9923935, y: -0.1519289}
  m_UseDelaunayMesh: 0
```

#### MultiHit [组件4110](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:70804>)

```yaml
PolygonCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1683}
  m_Enabled: 0
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Points:
    m_Paths:
    - - {x: 1.0162354, y: 0.5246668}
      - {x: -0.012817383, y: 1.1017241}
      - {x: 0.0024337769, y: -1.3007946}
      - {x: 1.1852646, y: -0.6203604}
      - {x: 5.0915985, y: -1.0493679}
      - {x: 5.7117004, y: -0.22890949}
      - {x: 4.9948044, y: 0.873168}
  m_UseDelaunayMesh: 0
```

#### Circle Slash 2 [组件4111](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:70858>)

```yaml
PolygonCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1624}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Points:
    m_Paths:
    - - {x: -1.2642975, y: 2.5130167}
      - {x: -2.215355, y: 1.7184019}
      - {x: -0.48641205, y: -0.10313702}
      - {x: 0.6120682, y: 1.3891525}
      - {x: 2.1688156, y: 1.1807032}
      - {x: 1.5204697, y: 2.1755629}
      - {x: 0.018371582, y: 2.7754412}
  m_UseDelaunayMesh: 0
```

#### Downstab Hit [组件4112](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:70912>)

```yaml
PolygonCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1582}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Points:
    m_Paths:
    - - {x: 0.7902069, y: 0.045175552}
      - {x: 0.12678528, y: -0.99011517}
      - {x: 1.6094055, y: -2.01237}
  m_UseDelaunayMesh: 0
```

#### Thwip Slash [组件4113](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:70962>)

```yaml
PolygonCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1379}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Points:
    m_Paths:
    - - {x: 1.8504257, y: 0.3592825}
      - {x: -0.7416153, y: 0.97131443}
      - {x: -1.5512009, y: 1.6220589}
      - {x: -1.3455963, y: 1.1798735}
      - {x: -0.7735214, y: 0.55630636}
      - {x: 0.6811447, y: -0.32446432}
      - {x: 1.536087, y: -0.43413115}
      - {x: 2.034851, y: -0.20766497}
  m_UseDelaunayMesh: 0
```

#### Combo Slash 2 [组件4114](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:71017>)

```yaml
PolygonCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1362}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Points:
    m_Paths:
    - - {x: -0.46990585, y: 1.8703003}
      - {x: -2.5160542, y: 0.8188858}
      - {x: 0.54447937, y: -0.86834717}
      - {x: 2.0004158, y: -0.617218}
      - {x: 3.0550117, y: -0.08100128}
      - {x: 3.6692276, y: 0.6626892}
      - {x: 3.3378105, y: 1.485321}
      - {x: 1.8162785, y: 1.9792786}
  m_UseDelaunayMesh: 0
```

#### lace collider [组件4183](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:74240>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1426}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 1, y: 1}
  m_EdgeRadius: 0
```

#### Battle Range2 [组件4208](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:75390>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1486}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: -1.5938683, y: 12.681397}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 14.514214, y: 29.24505}
  m_EdgeRadius: 0
```

#### Battle Range [组件4227](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:76264>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1691}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: -0.4597473, y: 12.681397}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 12.245972, y: 29.24505}
  m_EdgeRadius: 0
```

#### Attack Detector [组件4243](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:77000>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1836}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: -0.0078125, y: -0.25}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 0.828125, y: 2.5625}
  m_EdgeRadius: 0
```

#### NoThwhip Range [组件4245](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:77092>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1861}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0.5603895}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 9, y: 5.0030365}
  m_EdgeRadius: 0
```

#### Lace Boss1 [组件4250](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:77322>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1623}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 0
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: -0.0078125, y: -0.25}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 0.828125, y: 2.5625}
  m_EdgeRadius: 0
```

#### Lace Boss1 [组件6173](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:406523>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1623}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 7e0b9799fb0157646caefd91bc67f0a6, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  audioPlayerPrefab: {fileID: 82724804207875695, guid: 99068b2a95bddff419cb6f176648d4e6, type: 2}
  regularInvincibleAudio:
    Clip: {fileID: 8300000, guid: 6447a975892e6ac42be7525d74803f40, type: 3}
    PitchMin: 0.75
    PitchMax: 1.25
    Volume: 1
    vibrationDataAsset: {fileID: 0}
  blockHitPrefab: {fileID: 1709254077376921, guid: a7a57900a8a415a4387938611b64e586, type: 2}
  strikeNailPrefab: {fileID: 1709254077376921, guid: 64c20baf394ac9a41b03deea82568445, type: 2}
  slashImpactPrefab: {fileID: 1709254077376921, guid: 97c9ba031f06bae4681d3fda13c3f87b, type: 2}
  corpseSplatPrefab: {fileID: 1709254077376921, guid: ee26d04f9efdaa7458f4fcea07e485df, type: 2}
  hp: 250
  damageScaling:
    Level1Mult: 1
    Level2Mult: 1
    Level3Mult: 1
    Level4Mult: 1
    Level5Mult: 1
  enemyType: 0
  doNotGiveSilk: 0
  ignoreFlags: 0
  reaperBundles: 0
  effectOrigin: {x: 0, y: -0.2, z: 0}
  ignoreKillAll: 0
  sendDamageTo: {fileID: 0}
  isPartOfSendToTarget: 0
  tagDamageTakerIgnoreColliderState: 0
  takeTagDamageWhileInvincible: 0
  targetPointOverride: {fileID: 0}
  battleScene: {fileID: 0}
  sendHitTo: {fileID: 0}
  sendKilledToObject: {fileID: 0}
  sendKilledToName:
  smallGeoDrops: 0
  mediumGeoDrops: 0
  largeGeoDrops: 0
  largeSmoothGeoDrops: 0
  megaFlingGeo: 0
  shellShardDrops: 0
  flingSilkOrbsDown: 0
  flingSilkOrbsAimObject: {fileID: 0}
  itemDropGroups: []
  _itemDropProbability: 0
  _itemDrops: []
  hasAlternateHitAnimation: 0
  alternateHitAnimation: False
  invincible: 1
  piercable: 0
  invincibleFromDirection: 0
  preventInvincibleEffect: 1
  preventInvincibleShake: 0
  preventInvincibleAttackBlock: 0
  invincibleRecoil: 0
  dontSendTinkToDamager: 1
  hasAlternateInvincibleSound: 0
  alternateInvincibleSound: {fileID: 0}
  immuneToNailAttacks: 0
  immuneToExplosions: 0
  immuneToBeams: 0
  immuneToHunterWeapon: 0
  immuneToCoal: 0
  immuneToTraps: 0
  immuneToWater: 0
  immuneToSpikes: 0
  immuneToLava: 1
  isMossExtractable: 0
  isSwampExtractable: 0
  isBluebloodExtractable: 0
  deathAudioSnapshot: {fileID: 0}
  hasSpecialDeath: 0
  deathReset: 0
  damageOverride: 0
  ignoreAcid: 0
  ignoreWater: 0
  zeroHPEventOverride: {fileID: 0}
  dontDropMeat: 1
  enemySize: 1
  bigEnemyDeath: 0
  preventDeathAfterHero: 0
  ignoreHazards: 0
  invulnerableTime: 0.25
  semiPersistent: 0
  isDead: 0
  ignorePersistence: 0
  tinkTimer: 0
```

#### Combo Slash 1 [组件6644](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:460982>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1760}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 49c386a20fdaa83a59c1a091a909e14c, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  damageDealt: 1
  hazardType: 1
  damageAsset: {fileID: 0}
  damagePropertyFlags: 0
  resetOnEnable: 0
  canClashTink: 1
  forceParry: 0
  noClashFreeze: 0
  noTerrainThunk: 0
  noTerrainRecoil: 0
  noCorpseSpikeStick: 0
  noBounceCooldown: 0
  overrideCollisionSide: 0
  collisionSide: 0
  invertCollisionSide: 0
  HeroDamagedFSM: {fileID: 0}
  AlwaysSendDamaged: 0
  HeroDamagedFSMEvent:
  HeroDamagedFSMBool:
  HeroDamagedFSMGameObject:
  ClashEvents:
    OnClashUp:
      m_PersistentCalls:
        m_Calls: []
    OnClashDown:
      m_PersistentCalls:
        m_Calls: []
    OnClashLeft:
      m_PersistentCalls:
        m_Calls: []
    OnClashRight:
      m_PersistentCalls:
        m_Calls: []
  OnDamagedHero:
    m_PersistentCalls:
      m_Calls: []
```

#### Downstab Hit [组件6645](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:461030>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1582}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 49c386a20fdaa83a59c1a091a909e14c, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  damageDealt: 1
  hazardType: 1
  damageAsset: {fileID: 0}
  damagePropertyFlags: 0
  resetOnEnable: 0
  canClashTink: 0
  forceParry: 0
  noClashFreeze: 0
  noTerrainThunk: 0
  noTerrainRecoil: 0
  noCorpseSpikeStick: 0
  noBounceCooldown: 0
  overrideCollisionSide: 0
  collisionSide: 0
  invertCollisionSide: 0
  HeroDamagedFSM: {fileID: 0}
  AlwaysSendDamaged: 0
  HeroDamagedFSMEvent:
  HeroDamagedFSMBool:
  HeroDamagedFSMGameObject:
  ClashEvents:
    OnClashUp:
      m_PersistentCalls:
        m_Calls: []
    OnClashDown:
      m_PersistentCalls:
        m_Calls: []
    OnClashLeft:
      m_PersistentCalls:
        m_Calls: []
    OnClashRight:
      m_PersistentCalls:
        m_Calls: []
  OnDamagedHero:
    m_PersistentCalls:
      m_Calls: []
```

#### Lace Boss1 [组件6646](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:461078>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1623}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 49c386a20fdaa83a59c1a091a909e14c, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  damageDealt: 1
  hazardType: 1
  damageAsset: {fileID: 0}
  damagePropertyFlags: 0
  resetOnEnable: 0
  canClashTink: 0
  forceParry: 0
  noClashFreeze: 0
  noTerrainThunk: 0
  noTerrainRecoil: 0
  noCorpseSpikeStick: 0
  noBounceCooldown: 0
  overrideCollisionSide: 0
  collisionSide: 0
  invertCollisionSide: 0
  HeroDamagedFSM: {fileID: 0}
  AlwaysSendDamaged: 0
  HeroDamagedFSMEvent:
  HeroDamagedFSMBool:
  HeroDamagedFSMGameObject:
  ClashEvents:
    OnClashUp:
      m_PersistentCalls:
        m_Calls: []
    OnClashDown:
      m_PersistentCalls:
        m_Calls: []
    OnClashLeft:
      m_PersistentCalls:
        m_Calls: []
    OnClashRight:
      m_PersistentCalls:
        m_Calls: []
  OnDamagedHero:
    m_PersistentCalls:
      m_Calls: []
```

#### Circle Slash 2 [组件6648](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:461174>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1624}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 49c386a20fdaa83a59c1a091a909e14c, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  damageDealt: 1
  hazardType: 1
  damageAsset: {fileID: 0}
  damagePropertyFlags: 0
  resetOnEnable: 0
  canClashTink: 1
  forceParry: 0
  noClashFreeze: 0
  noTerrainThunk: 0
  noTerrainRecoil: 0
  noCorpseSpikeStick: 0
  noBounceCooldown: 0
  overrideCollisionSide: 0
  collisionSide: 0
  invertCollisionSide: 0
  HeroDamagedFSM: {fileID: 0}
  AlwaysSendDamaged: 0
  HeroDamagedFSMEvent:
  HeroDamagedFSMBool:
  HeroDamagedFSMGameObject:
  ClashEvents:
    OnClashUp:
      m_PersistentCalls:
        m_Calls: []
    OnClashDown:
      m_PersistentCalls:
        m_Calls: []
    OnClashLeft:
      m_PersistentCalls:
        m_Calls: []
    OnClashRight:
      m_PersistentCalls:
        m_Calls: []
  OnDamagedHero:
    m_PersistentCalls:
      m_Calls: []
```

#### Thwip Slash [组件6649](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:461222>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1379}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 49c386a20fdaa83a59c1a091a909e14c, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  damageDealt: 1
  hazardType: 1
  damageAsset: {fileID: 0}
  damagePropertyFlags: 0
  resetOnEnable: 0
  canClashTink: 1
  forceParry: 0
  noClashFreeze: 0
  noTerrainThunk: 0
  noTerrainRecoil: 0
  noCorpseSpikeStick: 0
  noBounceCooldown: 0
  overrideCollisionSide: 0
  collisionSide: 0
  invertCollisionSide: 0
  HeroDamagedFSM: {fileID: 0}
  AlwaysSendDamaged: 0
  HeroDamagedFSMEvent:
  HeroDamagedFSMBool:
  HeroDamagedFSMGameObject:
  ClashEvents:
    OnClashUp:
      m_PersistentCalls:
        m_Calls: []
    OnClashDown:
      m_PersistentCalls:
        m_Calls: []
    OnClashLeft:
      m_PersistentCalls:
        m_Calls: []
    OnClashRight:
      m_PersistentCalls:
        m_Calls: []
  OnDamagedHero:
    m_PersistentCalls:
      m_Calls: []
```

#### Combo Slash 2 [组件6650](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:461270>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1362}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 49c386a20fdaa83a59c1a091a909e14c, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  damageDealt: 1
  hazardType: 1
  damageAsset: {fileID: 0}
  damagePropertyFlags: 0
  resetOnEnable: 0
  canClashTink: 1
  forceParry: 0
  noClashFreeze: 0
  noTerrainThunk: 0
  noTerrainRecoil: 0
  noCorpseSpikeStick: 0
  noBounceCooldown: 0
  overrideCollisionSide: 0
  collisionSide: 0
  invertCollisionSide: 0
  HeroDamagedFSM: {fileID: 0}
  AlwaysSendDamaged: 0
  HeroDamagedFSMEvent:
  HeroDamagedFSMBool:
  HeroDamagedFSMGameObject:
  ClashEvents:
    OnClashUp:
      m_PersistentCalls:
        m_Calls: []
    OnClashDown:
      m_PersistentCalls:
        m_Calls: []
    OnClashLeft:
      m_PersistentCalls:
        m_Calls: []
    OnClashRight:
      m_PersistentCalls:
        m_Calls: []
  OnDamagedHero:
    m_PersistentCalls:
      m_Calls: []
```

#### Charge Hit [组件6651](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:461318>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1548}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 49c386a20fdaa83a59c1a091a909e14c, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  damageDealt: 1
  hazardType: 1
  damageAsset: {fileID: 0}
  damagePropertyFlags: 0
  resetOnEnable: 0
  canClashTink: 1
  forceParry: 0
  noClashFreeze: 0
  noTerrainThunk: 0
  noTerrainRecoil: 0
  noCorpseSpikeStick: 0
  noBounceCooldown: 0
  overrideCollisionSide: 0
  collisionSide: 0
  invertCollisionSide: 0
  HeroDamagedFSM: {fileID: 0}
  AlwaysSendDamaged: 0
  HeroDamagedFSMEvent:
  HeroDamagedFSMBool:
  HeroDamagedFSMGameObject:
  ClashEvents:
    OnClashUp:
      m_PersistentCalls:
        m_Calls: []
    OnClashDown:
      m_PersistentCalls:
        m_Calls: []
    OnClashLeft:
      m_PersistentCalls:
        m_Calls: []
    OnClashRight:
      m_PersistentCalls:
        m_Calls: []
  OnDamagedHero:
    m_PersistentCalls:
      m_Calls: []
```

#### Circle Slash 1 [组件6652](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:461366>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1588}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 49c386a20fdaa83a59c1a091a909e14c, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  damageDealt: 1
  hazardType: 1
  damageAsset: {fileID: 0}
  damagePropertyFlags: 0
  resetOnEnable: 0
  canClashTink: 1
  forceParry: 0
  noClashFreeze: 0
  noTerrainThunk: 0
  noTerrainRecoil: 0
  noCorpseSpikeStick: 0
  noBounceCooldown: 0
  overrideCollisionSide: 0
  collisionSide: 0
  invertCollisionSide: 0
  HeroDamagedFSM: {fileID: 0}
  AlwaysSendDamaged: 0
  HeroDamagedFSMEvent:
  HeroDamagedFSMBool:
  HeroDamagedFSMGameObject:
  ClashEvents:
    OnClashUp:
      m_PersistentCalls:
        m_Calls: []
    OnClashDown:
      m_PersistentCalls:
        m_Calls: []
    OnClashLeft:
      m_PersistentCalls:
        m_Calls: []
    OnClashRight:
      m_PersistentCalls:
        m_Calls: []
  OnDamagedHero:
    m_PersistentCalls:
      m_Calls: []
```

#### MultiHit [组件6653](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:461414>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1683}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 49c386a20fdaa83a59c1a091a909e14c, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  damageDealt: 0
  hazardType: 1
  damageAsset: {fileID: 0}
  damagePropertyFlags: 0
  resetOnEnable: 0
  canClashTink: 1
  forceParry: 0
  noClashFreeze: 0
  noTerrainThunk: 0
  noTerrainRecoil: 0
  noCorpseSpikeStick: 0
  noBounceCooldown: 0
  overrideCollisionSide: 0
  collisionSide: 0
  invertCollisionSide: 0
  HeroDamagedFSM: {fileID: 0}
  AlwaysSendDamaged: 0
  HeroDamagedFSMEvent:
  HeroDamagedFSMBool:
  HeroDamagedFSMGameObject:
  ClashEvents:
    OnClashUp:
      m_PersistentCalls:
        m_Calls: []
    OnClashDown:
      m_PersistentCalls:
        m_Calls: []
    OnClashLeft:
      m_PersistentCalls:
        m_Calls: []
    OnClashRight:
      m_PersistentCalls:
        m_Calls: []
  OnDamagedHero:
    m_PersistentCalls:
      m_Calls: []
```

## Trobbio

### Trobbio / Control [fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:1495>)

变量初值：`{"floatVariables":{"X Speed":0,"(blank)":0,"Tornado Speed":0,"Tornado Time":0,"Tornado X Min":66,"Tornado X Max":82,"Self X":0,"Floor Y":16.34,"Distance":0,"Centre X":74,"X Pos Current":0,"X Pos Target":0,"Difference":0,"Stun Timer":0,"Pitch":0,"Bomb Rotation":0,"Current Y":0,"Max Y":25.91,"Target Y":0,"Y Pos":0},"intVariables":{"Poses":0,"Extra Poses":0,"Retry":0,"Death Poses":0,"P2 HP":0},"boolVariables":{"(blank)":0,"Below P2 HP":0,"Can Evade":0,"Centred":0,"Close to Hero":0,"Doing First Attack":1,"Doing First Burst Column":0,"Enough Poses":0,"Evade Cooling Down":0,"Flare Glitter Active":0,"Force Centre":0,"Hornet Is Dead":0,"In Evade Range":0,"In Range":0,"Phase 2":0,"Timer End":0,"Wall Behind":0,"Will Burst Column":0},"stringVariables":{"Pose Anim":null},"vector3Variables":{"Throw Point Vector":{"x":0,"y":0,"z":0}},"gameObjectVariables":{"(blank)":{"fileID":0},"Boss Scene":{"fileID":0},"CamLock Boss":{"fileID":0},"CamLock Intro":{"fileID":0},"Confetti Shooters":{"fileID":0},"Damage Collider":{"fileID":1025901758691103},"Dazzle Flash":{"fileID":1730242686860875},"Flare Glitter":{"fileID":0},"Floor Bouncer":{"fileID":1985305603660343},"Gates":{"fileID":0},"Kill Hit":{"fileID":1711914853252429},"Projectile":{"fileID":0},"Pt Bomb Throw":{"fileID":1709867586078768},"Pt Entry Antic":{"fileID":1161607090078389},"Pt Exit":{"fileID":1705390221481576},"Pt IdleGlitter":{"fileID":1470112387431263},"Pt JumpDust":{"fileID":1969106005120503},"Pt KillHit":{"fileID":1918264173551851},"Pt Land":{"fileID":1302127217294661},"Pt SpinDust":{"fileID":1634108722742392},"Pt Stun":{"fileID":0},"Pt Tornado Dust":{"fileID":1313026266067498},"Ray Pt Centre":{"fileID":1044625135789424},"Self":{"fileID":0},"Spotlight L":{"fileID":0},"Spotlight R":{"fileID":0},"Start Range":{"fileID":0},"Steam Jets":{"fileID":0},"Throw Point":{"fileID":1587765826080250},"Tornado Damager":{"fileID":1372920208702427},"Tornado Disperse":{"fileID":0},"Trapdoor L":{"fileID":1336590748365959},"Trapdoor R":{"fileID":1256069497284392},"Pt DeathStream":{"fileID":1587397909062814},"Bind Dazzle Pickup":{"fileID":0},"Pickup Spot":{"fileID":1875609422105747},"FakeDeath Range":{"fileID":1694121525821480},"Fake Death Sprite":{"fileID":1371939378208658},"FakeDeath ExitRange":{"fileID":1320256170494724},"Smoke Loop":{"fileID":0},"Drum Loop":{"fileID":0},"Tornado Loop":{"fileID":0},"Fly Loop":{"fileID":0},"Start Range Meet":{"fileID":0},"Flinch Detector":{"fileID":1217368724061974},"Pt Intro Steam":{"fileID":0},"Dazzle Damager":{"fileID":0},"Smoke Trapdoor Loop":{"fileID":1089843903986396},"Death Fireworks Loop":{"fileID":1672306508523268},"Terrain Saver":{"fileID":1900271049623953},"Tornado Event Sender":{"fileID":1472185465350827},"Trapdoor Bursts":{"fileID":0},"Final Burst":{"fileID":0},"Audio Loop Fake Death":{"fileID":1220653531496868},"Audio Loop Voice":{"fileID":1967328832014496}}}`

全局迁移：`[{"fsmEvent":{"name":"STUN","isSystemEvent":0,"isGlobal":0},"toState":"Stun Start","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0},{"fsmEvent":{"name":"ZERO HP","isSystemEvent":0,"isGlobal":0},"toState":"Death Hit","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0}]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:1512>)

出口：FINISHED → State。isSequence=0。

1. `GetOwner(storeGameObject="$Self")`

2. `ActivateInteractible(Target="Self", Activate=0, AllowQueueing=0, UseChildren=0)`

3. `GetParent(gameObject="Self", storeResult="$Boss Scene")`

4. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Confetti Shooters")`

5. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Smoke Loop")`

6. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Drum Loop")`

7. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Steam Jets")`

8. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Flare Glitter")`

9. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Spotlight L")`

10. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Spotlight R")`

11. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Start Range")`

12. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Start Range Meet")`

13. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Gates")`

14. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$CamLock Boss")`

15. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$CamLock Intro")`

16. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Pt Intro Steam")`

17. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Trapdoor Bursts")`

18. `FindNamedChild(gameObject="Self", storeResult="$Tornado Loop")`

19. `FindNamedChild(gameObject="Self", storeResult="$Fly Loop")`

20. `SetParent(gameObject="Owner($Trapdoor L)", parent="fileID:0", resetLocalPosition=0, resetLocalRotation=0)`

21. `SetParent(gameObject="Owner($Trapdoor R)", parent="fileID:0", resetLocalPosition=0, resetLocalRotation=0)`

22. `FindChild(gameObject="Owner($Boss Scene)", childName="Collectable Item Pickup", storeResult="$Bind Dazzle Pickup")`

23. `GetHP(target="Self", storeValue="$P2 HP")`

24. `MultiplyIntByFloat(integer="$P2 HP", multiplyFloat=0.5, storeResult="$P2 HP", everyFrame=false, forceRoundUp=false)`

25. `NextFrameEvent(sendEvent="FINISHED")`

26. `SetCollider(gameObject="Self", active=0, resetOnExit=false)`



#### Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:2075>)

出口：FINISHED → Pose Set；TOOK DAMAGE → Pose Set。isSequence=0。

1. `Wait(time=0.3, finishEvent="FINISHED", realTime=false)`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Idle")`



#### Throw Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:2182>)

出口：FINISHED → Throw。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Throw", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`

2. `SetBoolValue(boolVariable="$Doing First Attack", boolValue=0, everyFrame=false)`

3. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

4. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:6de4b2fc7cb238e4780b915dfb3a086c#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

5. `AudioPlayRandomVoiceFromTable(gameObject="Self", audioClipTable="GUID:00245b57a4ba4ec4681a896947d10a28#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`



#### Throw · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:2399>)

出口：FINISHED → Fall?。isSequence=0。

1. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:0f7482984b2251c4e8b2819d005990a3#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

2. `Tk2dWatchAnimationEvents(gameObject="Self", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `GetPosition(gameObject="Owner($Throw Point)", vector="$Throw Point Vector", x="None", y="$Current Y", z="None", space=0, everyFrame=false)`

4. `SetFloatToLowest(floatVariable="$Current Y", value1="$Current Y", value2="$Max Y", everyFrame=false)`

5. `SetVector3XYZ(vector3Variable="$Throw Point Vector", vector3Value="None", x="None", y="$Current Y", z="None", everyFrame=false)`

6. `SpawnObjectFromGlobalPool(gameObject="GUID:04bfbcef4b02e2e4b9fb18f9d0b7a165#1709254077376921", spawnPoint="None", position="$Throw Point Vector", rotation="None", storeObject="$Projectile")`

7. `RandomFloat(min=15, max=15, storeResult="$X Speed")`

8. `SetFsmFloat(gameObject="Owner($Projectile)", fsmName="Control", variableName="X Velocity", setValue="$X Speed", everyFrame=false)`

9. `SetVelocity2d(gameObject="Owner($Projectile)", vector="None", x="$X Speed", y="None", everyFrame=false)`

10. **disabled** `FloatAdd(floatVariable="$Bomb Rotation", add=90, everyFrame=false, perSecond=false)`

11. `SetFsmFloat(gameObject="Owner($Projectile)", fsmName="Control", variableName="Rotation", setValue=0, everyFrame=false)`

12. `SpawnObjectFromGlobalPool(gameObject="GUID:04bfbcef4b02e2e4b9fb18f9d0b7a165#1709254077376921", spawnPoint="None", position="$Throw Point Vector", rotation="None", storeObject="$Projectile")`

13. `RandomFloat(min=-15, max=-15, storeResult="$X Speed")`

14. `SetFsmFloat(gameObject="Owner($Projectile)", fsmName="Control", variableName="X Velocity", setValue="$X Speed", everyFrame=false)`

15. `SetVelocity2d(gameObject="Owner($Projectile)", vector="None", x="$X Speed", y="None", everyFrame=false)`

16. **disabled** `FloatAdd(floatVariable="$Bomb Rotation", add=90, everyFrame=false, perSecond=false)`

17. `SetFsmFloat(gameObject="Owner($Projectile)", fsmName="Control", variableName="Rotation", setValue=90, everyFrame=false)`

18. `SpawnObjectFromGlobalPool(gameObject="GUID:04bfbcef4b02e2e4b9fb18f9d0b7a165#1709254077376921", spawnPoint="None", position="$Throw Point Vector", rotation="None", storeObject="$Projectile")`

19. `RandomFloatEither(value1=-3, value2=3, storeResult="$X Speed")`

20. `SetFsmFloat(gameObject="Owner($Projectile)", fsmName="Control", variableName="X Velocity", setValue="$X Speed", everyFrame=false)`

21. `SetVelocity2d(gameObject="Owner($Projectile)", vector="None", x="$X Speed", y="None", everyFrame=false)`

22. **disabled** `FloatAdd(floatVariable="$Bomb Rotation", add=90, everyFrame=false, perSecond=false)`

23. `SetFsmFloat(gameObject="Owner($Projectile)", fsmName="Control", variableName="Rotation", setValue=180, everyFrame=false)`

24. `PlayParticleEmitter(gameObject="Owner($Pt Bomb Throw)", emit=0, resetIfPlaying=false)`



#### Choice · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:3187>)

出口：DAZZLE FLASH → Flash Antic；TORNADO → Tornado Antic；BOMB THROW → Throw Antic；JUMP → Jump Antic；EXIT → Exit 1；HORNET DEAD → Hornet Dead；BURST COLUMNS → Will Burst Column；TO P2 → Phase Roar Antic；SING → Sing。isSequence=0。

1. `SetIntValue(intVariable="$Extra Poses", intValue=0, everyFrame=false)`

2. **disabled** `SendEvent(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="BURST COLUMNS", delay=0, everyFrame=false)`

3. `CheckHeroPerformanceRegionV2(Target="Self", Radius=0, MinReactDelay=0, MaxReactDelay=0, None=null, ActiveInner="SING", ActiveOuter=null, IgnoreNeedolinRange=0, UseActiveBool=0, ActiveBool="None", StoreState="None", EveryFrame=false)`

4. `SendRandomEventV4(events=["TORNADO","BOMB THROW","JUMP"], weights=[1,1,1], eventMax=[1,1,1], missedMax=[5,5,4], activeBool="$Doing First Attack")`

5. `BoolTest(boolVariable="$Hornet Is Dead", isTrue="HORNET DEAD", isFalse=null, everyFrame=false)`

6. `CompareHPBool(enemy="$Self", compareTo="$P2 HP", equalBool=0, lessThanBool="$Below P2 HP", greaterThanBool=0, everyFrame=false)`

7. `BoolTestMulti(boolVariables=["$Below P2 HP","$Phase 2"], boolStates=[1,0], trueEvent="TO P2", falseEvent=null, storeResult="None", everyFrame=false)`

8. `BoolTest(boolVariable="$Doing First Burst Column", isTrue="TORNADO", isFalse=null, everyFrame=false)`

9. `SendRandomEventV4(events=["TORNADO","BOMB THROW","DAZZLE FLASH","JUMP","BURST COLUMNS"], weights=[1,1,1,1,1], eventMax=[1,1,1,1,1], missedMax=[5,5,4,4,4], activeBool="$Phase 2")`

10. `SendRandomEventV4(events=["TORNADO","BOMB THROW","DAZZLE FLASH","JUMP","EXIT"], weights=[1,1,1,1,0.75], eventMax=[1,1,1,1,1], missedMax=[5,5,4,3,4], activeBool="None")`



#### Flash Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:3912>)

出口：FINISHED → Flash Start；CANCEL → Choice。isSequence=0。

1. `GetFsmBool(gameObject="Owner($Flare Glitter)", fsmName="Control", variableName="Active", storeValue="$Flare Glitter Active", everyFrame=false)`

2. `BoolTest(boolVariable="$Flare Glitter Active", isTrue="CANCEL", isFalse=null, everyFrame=false)`

3. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

4. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Antic", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

5. **disabled** `SendEventByNameV2(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Steam Jets)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="PLAY", delay=0, everyFrame=false)`

6. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:0e0686f9ecd22fb45a43c145e0ea3893#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Flash Start · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:4196>)

出口：FINISHED → Flash Rise。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Flash Attack", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`



#### Flash Burst · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:4279>)

出口：FINISHED → Fall。isSequence=0。

1. `Tk2dWatchAnimationEvents(gameObject="Self", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `DecelerateV2(gameObject="Self", deceleration=0.825, brakeOnExit=false)`

3. `ActivateGameObject(gameObject="Owner($Dazzle Flash)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

4. `ActivateGameObject(gameObject="Owner($Dazzle Flash)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

5. **disabled** `SendEventByNameV2(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Confetti Shooters)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="PLAY", delay=0, everyFrame=false)`

6. `ScreenFlashTrobbio()`

7. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Flare Glitter)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="FLARE GLITTER", delay=0, everyFrame=false)`



#### Land · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:4530>)

出口：FINISHED → Post Dazzle Idle。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Land Quick", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `SetVelocity2d(gameObject="Self", vector={"x":0,"y":0}, x="None", y="None", everyFrame=false)`

3. `PlayParticleEmitter(gameObject="Owner($Pt Land)", emit=0, resetIfPlaying=true)`

4. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:7930b85c540bf474581e7fda7871306b#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Flash Rise · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:4724>)

出口：FINISHED → Flash Burst。isSequence=0。

1. `SetGravity2dScale(gameObject="Self", gravityScale=0)`

2. `SetVelocity2d(gameObject="Self", vector="None", x="None", y=40, everyFrame=false)`

3. `Tk2dWatchAnimationEvents(gameObject="Self", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`

4. `DecelerateV2(gameObject="Self", deceleration=0.825, brakeOnExit=false)`

5. `SendEventByNameV2(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Steam Jets)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="STOP", delay=0, everyFrame=false)`

6. `PlayParticleEmitter(gameObject="Owner($Pt JumpDust)", emit=0, resetIfPlaying=false)`

7. `AudioPlayRandomVoiceFromTable(gameObject="Self", audioClipTable="GUID:a4fd2c9fc694d844492a16e3e1f5c595#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`

8. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:9edc4820c94536845964fb16515538f7#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Fall · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:5020>)

出口：LAND → Land。isSequence=0。

1. `SetGravity2dScale(gameObject="Self", gravityScale=1)`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Fall")`

3. `CheckCollisionSide(collidingObject="Self", topHit="None", rightHit="None", bottomHit="None", leftHit="None", topHitEvent=null, rightHitEvent=null, bottomHitEvent="LAND", leftHitEvent=null, otherLayer=false, otherLayerNumber=0, ignoreTriggers=0)`

4. `CheckCollisionSideEnter(topHit="None", rightHit="None", bottomHit="None", leftHit="None", topHitEvent=null, rightHitEvent=null, bottomHitEvent="LAND", leftHitEvent=null, otherLayer=false, otherLayerNumber=0, ignoreTriggers=0)`



#### Tornado Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:5227>)

出口：FINISHED → Tornado Antic 2。isSequence=0。

1. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

2. `SetBoolValue(boolVariable="$Doing First Attack", boolValue=0, everyFrame=false)`

3. `SetBoolValue(boolVariable="$Doing First Burst Column", boolValue=0, everyFrame=false)`

4. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Antic", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

5. `DecelerateV2(gameObject="Self", deceleration=0.85, brakeOnExit=true)`

6. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:0e0686f9ecd22fb45a43c145e0ea3893#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Tornado · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:5458>)

出口：WALL → Tornado Turn；END → Tornado Slow；MULTI HIT CONNECT → Tornado Multihit。isSequence=0。

1. `AccelerateToX(gameObject="Self", accelerationFactor=0.6, targetSpeed="$Tornado Speed")`

2. `RayCast2dV2(fromGameObject="Owner($Ray Pt Centre)", fromPosition="None", direction={"x":1,"y":0}, space=1, distance=1.7, minDepth="None", maxDepth="None", hitEvent="WALL", noHitEvent=null, storeDidHit="None", storeHitObject="None", storeHitPoint="None", storeHitNormal="None", storeHitDistance="None", storeDistance="None", repeatInterval=1, layerMask=[8], invertMask=0, ignoreTriggers=0, debugColor={"r":1,"g":0.92156863,"b":0.015686275,"a":1}, debug=1)`

3. `FloatAdd(floatVariable="$Tornado Time", add=-1, everyFrame=true, perSecond=true)`

4. `FloatTestToBool(float1="$Tornado Time", float2=0, tolerance=0, equalBool="None", lessThanBool="$Timer End", greaterThanBool="None", everyFrame=true)`

5. `GetPosition(gameObject="Self", vector="None", x="$Self X", y="None", z="None", space=0, everyFrame=true)`

6. `FloatInRange(floatVariable="$Self X", lowerValue="$Tornado X Min", upperValue="$Tornado X Max", boolVariable="$In Range", trueEvent=null, falseEvent=null, everyFrame=true)`

7. `BoolAllTrue(boolVariables=["$In Range","$Timer End"], sendEvent="END", storeResult="None", everyFrame=true)`



#### Tornado Turn · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:5866>)

出口：FINISHED → Tornado。isSequence=0。

1. `GetVelocity2dNotZero(gameObject="Self", vector="None", x="$X Speed", y="None", space=0, everyFrame=false)`

2. `FloatMultiply(floatVariable="$X Speed", multiplyBy=-1, everyFrame=false)`

3. `FloatMultiply(floatVariable="$Tornado Speed", multiplyBy=-1, everyFrame=false)`

4. `SetVelocity2d(gameObject="Self", vector="None", x="$X Speed", y="None", everyFrame=false)`

5. `FlipScale(gameObject="Self", flipHorizontally=true, flipVertically=false, everyFrame=false, lateUpdate=false)`



#### Tornado Start · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:6043>)

出口：FINISHED → Tornado。isSequence=0。

1. `ActivateGameObject(gameObject="Owner($Tornado Damager)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

2. `ActivateGameObject(gameObject="Owner($Tornado Event Sender)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

3. `ActivateGameObject(gameObject="Owner($Damage Collider)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

4. `PlayParticleEmitterChildren(gameObject="Owner($Pt Tornado Dust)", resetTimeIfPlaying=true, stopOnStateExit=false)`

5. `RandomFloat(min=1.6, max=1.6, storeResult="$Tornado Time")`

6. `SetGravity2dScale(gameObject="Self", gravityScale=0.5)`

7. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Tornado")`

8. `SetFloatValue(floatVariable="$Tornado Speed", floatValue=22, everyFrame=false)`

9. `SetInvincible(target="Self", Invincible=1, InvincibleFromDirection=13, resetOnStateExit=false)`

10. `SendEventByScale(gameObject="Self", eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, xScale=true, positiveEvent="FINISHED", negativeEvent=null, space=0)`

11. `SetFloatValue(floatVariable="$Tornado Speed", floatValue=-22, everyFrame=false)`



#### Tornado End · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:6374>)

出口：FINISHED → Tornado Pose。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Tornado End", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `DecelerateXY(gameObject="Self", decelerationX=0.85, decelerationY="None", brakeOnExit=true)`

3. `SetGravity2dScale(gameObject="Self", gravityScale=1)`



#### Pose Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:6501>)

出口：FINISHED → Pose?；EVADE → Tornado Evade；TOOK DAMAGE → Evade?；TO P2 → Phase Roar Antic。isSequence=0。

1. `SelectRandomString(strings=["Pose 1","Pose 2","Pose 3"], weights=[1,1,1], storeString="$Pose Anim")`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="$Pose Anim")`

3. `Wait(time=0.5, finishEvent="FINISHED", realTime=false)`

4. `CompareHPBool(enemy="$Self", compareTo="$P2 HP", equalBool=0, lessThanBool="$Below P2 HP", greaterThanBool=0, everyFrame=false)`

5. `BoolTestMulti(boolVariables=["$Below P2 HP","$Phase 2"], boolStates=[1,0], trueEvent="TO P2", falseEvent=null, storeResult="None", everyFrame=false)`

6. `SetBoolValueAtTime(BoolVariable="$Can Evade", BoolValue=1, Time=0.25, SetOppositeOnStateEntry=true)`

7. `BoolTestMulti(boolVariables=["$Evade Cooling Down","$Can Evade","$In Evade Range"], boolStates=[0,1,1], trueEvent="EVADE", falseEvent=null, storeResult="None", everyFrame=true)`



#### Tornado Shoot · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:6849>)

出口：FINISHED → Tornado End。isSequence=0。

1. `AudioStop(gameObject="Owner($Tornado Loop)", fadeTime=0)`

2. `SetDamageHero(Target="Self", Enabled=1)`

3. `AudioPlayRandomVoiceFromTable(gameObject="Self", audioClipTable="GUID:00245b57a4ba4ec4681a896947d10a28#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`

4. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:da6ce3443f5bf8d4ebd2479c26e88434#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

5. `ActivateGameObject(gameObject="Owner($Tornado Disperse)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

6. `SpawnObjectFromGlobalPool(gameObject="GUID:0477261675dc04c408016032bc0b1626#1709254077376921", spawnPoint="$Self", position={"x":0.75,"y":-3.1,"z":-0.001}, rotation="None", storeObject="$Projectile")`

7. `SetScale(gameObject="Owner($Projectile)", vector="None", x=1, y="None", z="None", everyFrame=false, lateUpdate=false)`

8. `SpawnObjectFromGlobalPool(gameObject="GUID:0477261675dc04c408016032bc0b1626#1709254077376921", spawnPoint="$Self", position={"x":-0.75,"y":-3.1,"z":-0.001}, rotation="None", storeObject="$Projectile")`

9. `SetScale(gameObject="Owner($Projectile)", vector="None", x=-1, y="None", z="None", everyFrame=false, lateUpdate=false)`

10. `ActivateGameObject(gameObject="Owner($Tornado Damager)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

11. `ActivateGameObject(gameObject="Owner($Tornado Event Sender)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

12. `ActivateGameObject(gameObject="Owner($Damage Collider)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

13. `StopParticleEmittersInChildren(gameObject="Owner($Pt Tornado Dust)")`

14. `SetInvincible(target="Self", Invincible=0, InvincibleFromDirection=13, resetOnStateExit=false)`



#### Tornado Slow · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:7328>)

出口：FINISHED → Tornado Shoot；MULTI HIT CONNECT → Tornado Multihit。isSequence=0。

1. `DecelerateXY(gameObject="Self", decelerationX=0.9, decelerationY="None", brakeOnExit=false)`

2. `Wait(time=0.3, finishEvent="FINISHED", realTime=false)`

3. `EaseFloat(fromValue=1, toValue=0.75, floatVariable="$Pitch", time=0.3, speed="None", delay="None", easeType=21, reverse=0, finishEvent=null, realTime=false)`

4. `SetAudioPitch(gameObject="Owner($Tornado Loop)", pitch="$Pitch", everyFrame=true)`



#### Exit 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:7510>)

出口：FINISHED → Exit 2。isSequence=0。

1. `CancelRecoil(target="Self")`

2. `SetRecoilBlocked(Target="Self", IsUpBlocked=1, IsDownBlocked=0, IsLeftBlocked=0, IsRightBlocked=0)`

3. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Exit", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`

4. `AudioPlayRandomVoiceFromTable(gameObject="Self", audioClipTable="GUID:a4fd2c9fc694d844492a16e3e1f5c595#11400000", pitchOffset=0, stopPreviousSound=false, forcePlay=false)`

5. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:47d5f2aaab7426b44ad5c2e661f76f71#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Exit 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:7724>)

出口：FINISHED → Exit Pause。isSequence=0。

1. `Tk2dWatchAnimationEvents(gameObject="Self", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `SetIsKinematic2d(gameObject="Self", isKinematic=1)`

3. `SetCollider(gameObject="Self", active=0, resetOnExit=false)`

4. `PlayParticleEmitter(gameObject="Owner($Pt Exit)", emit=0, resetIfPlaying=false)`

5. `ActivateGameObject(gameObject="Owner($Damage Collider)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

6. `StopParticleEmitter(gameObject="Owner($Pt IdleGlitter)")`

7. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:0c70141410f9dbc43ae648b4b09858bc#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Pose? · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:7953>)

出口：POSE → Spin Check；FINISHED → Evade?；SING → Sing。isSequence=0。

1. `CheckHeroPerformanceRegionV2(Target="Self", Radius=0, MinReactDelay=0, MaxReactDelay=0, None=null, ActiveInner="SING", ActiveOuter=null, IgnoreNeedolinRange=0, UseActiveBool=0, ActiveBool="None", StoreState="None", EveryFrame=false)`

2. `IntAdd(intVariable="$Poses", add=-1, everyFrame=false)`

3. `IntCompare(integer1="$Poses", integer2=0, equal="FINISHED", lessThan="FINISHED", greaterThan="POSE", everyFrame=false)`

4. **disabled** `SendRandomEventV4(events=["FINISHED","POSE"], weights=[0.5,0.5], eventMax=[2,2], missedMax=[3,3], activeBool="None")`



#### Spin Check · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:8203>)

出口：CANCEL → Evade?；FORWARD → Spin F；BACK → Spin B。isSequence=0。

1. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

2. `RayCast2dV2(fromGameObject="Owner($Ray Pt Centre)", fromPosition="None", direction={"x":-1,"y":0}, space=1, distance=5, minDepth="None", maxDepth="None", hitEvent=null, noHitEvent=null, storeDidHit="$Wall Behind", storeHitObject="None", storeHitPoint="None", storeHitNormal="None", storeHitDistance="None", storeDistance="None", repeatInterval=0, layerMask=[8], invertMask=0, ignoreTriggers=0, debugColor={"r":1,"g":0.92156863,"b":0.015686275,"a":1}, debug=0)`

3. `GetXDistance(gameObject="Self", target="$Hero", storeResult="$Distance", everyFrame=false)`

4. `FloatTestToBool(float1="$Distance", float2=10, tolerance=0, equalBool="None", lessThanBool="$Close to Hero", greaterThanBool="None", everyFrame=false)`

5. `BoolTestMulti(boolVariables=["$Close to Hero","$Wall Behind"], boolStates=[1,1], trueEvent="CANCEL", falseEvent=null, storeResult="None", everyFrame=false)`

6. `BoolTestMulti(boolVariables=["$Close to Hero","$Wall Behind"], boolStates=[1,0], trueEvent="BACK", falseEvent=null, storeResult="None", everyFrame=false)`

7. `BoolTestMulti(boolVariables=["$Close to Hero","$Wall Behind"], boolStates=[0,1], trueEvent="FORWARD", falseEvent=null, storeResult="None", everyFrame=false)`

8. `SendRandomEvent(events=["FORWARD","BACK"], weights=[1,1], delay=0)`



#### Spin F · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:8695>)

出口：FINISHED → Spin。isSequence=0。

1. `SetVelocityByScale(gameObject="Self", speed=42, ySpeed="None", everyFrame=false)`



#### Spin B · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:8782>)

出口：FINISHED → Spin。isSequence=0。

1. `SetVelocityByScale(gameObject="Self", speed=-42, ySpeed="None", everyFrame=false)`



#### Spin · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:8869>)

出口：FINISHED → Pose Idle。isSequence=0。

1. `AudioPlayRandomVoiceFromTable(gameObject="Self", audioClipTable="GUID:00245b57a4ba4ec4681a896947d10a28#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`

2. `AudioPlayerOneShot(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClips=["GUID:78e5b1dbedf70944eacfdcd958d9b83f#8300000","GUID:1f9e86ed6916e964b86cbe8b16c513e4#8300000","GUID:98513f445f4b77a4f953c3cfe03146f9#8300000"], weights=[1,1,1], pitchMin=0.85, pitchMax=1.15, volume=1, delay=0, storePlayer="fileID:0")`

3. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Idle Spin", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

4. `DecelerateXY(gameObject="Self", decelerationX=0.875, decelerationY="None", brakeOnExit=true)`

5. `PlayParticleEmitter(gameObject="Owner($Pt SpinDust)", emit=0, resetIfPlaying=true)`



#### Tornado Pose · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:9101>)

出口：FINISHED → Pose Set；EVADE → Tornado Evade；TOOK DAMAGE → Tornado Evade。isSequence=0。

1. `SelectRandomString(strings=["Pose 1","Pose 2","Pose 3"], weights=[1,1,1], storeString="$Pose Anim")`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="$Pose Anim")`

3. `Wait(time=0.5, finishEvent="FINISHED", realTime=false)`

4. `AudioPlayerOneShot(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClips=["GUID:78e5b1dbedf70944eacfdcd958d9b83f#8300000","GUID:1f9e86ed6916e964b86cbe8b16c513e4#8300000","GUID:98513f445f4b77a4f953c3cfe03146f9#8300000"], weights=[1,1,1], pitchMin=0.85, pitchMax=1.15, volume=1, delay=0, storePlayer="fileID:0")`

5. `SetBoolValueAtTime(BoolVariable="$Can Evade", BoolValue=1, Time=0.35, SetOppositeOnStateEntry=false)`

6. `CheckAlertRangeByName(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, alertRangeName="Evade Tornado Range", storeResult="$In Evade Range", sendEvent=null, outOfRangeEvent=null, everyFrame=true)`

7. `BoolAllTrue(boolVariables=["$Can Evade","$In Evade Range"], sendEvent="EVADE", storeResult="None", everyFrame=true)`



#### Pose Set · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:9465>)

出口：FINISHED → Evade?。isSequence=0。

1. `RandomInt(min=1, max=2, storeResult="$Poses", inclusiveMax=true, noRepeat=0)`

2. `IntAdd(intVariable="$Poses", add="$Extra Poses", everyFrame=false)`

3. `SetIntValue(intVariable="$Extra Poses", intValue=0, everyFrame=false)`



#### Throw Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:9591>)

出口：FINISHED → Pose?。isSequence=0。

1. `Wait(time=0.5, finishEvent="FINISHED", realTime=false)`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Idle")`

3. `SetIntValue(intVariable="$Poses", intValue=3, everyFrame=false)`



#### Jump Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:9706>)

出口：FINISHED → Jump。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Jump Antic", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `SetBoolValue(boolVariable="$Doing First Attack", boolValue=0, everyFrame=false)`

3. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

4. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:0e0686f9ecd22fb45a43c145e0ea3893#8300000", pitchMin=0.85, pitchMax=1.15, volume=1, delay=0, storePlayer="fileID:0")`



#### Jump · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:9901>)

出口：FINISHED → Fly Dir。isSequence=0。

1. `SetBoolValue(boolVariable="$Will Burst Column", boolValue=0, everyFrame=false)`

2. `AudioPlayRandomVoiceFromTable(gameObject="Self", audioClipTable="GUID:00245b57a4ba4ec4681a896947d10a28#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`

3. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Jump")`

4. `SetVelocity2d(gameObject="Self", vector="None", x="None", y=30, everyFrame=false)`

5. `WaitRandom(timeMin=0.25, timeMax=0.3, finishEvent="FINISHED", realTime=false)`

6. `PlayParticleEmitter(gameObject="Owner($Pt JumpDust)", emit=0, resetIfPlaying=false)`

7. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:05014101a5989d94da43736874583fdd#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

8. `SetRecoilSpeed(target="Self", newRecoilSpeed=15)`



#### Fly Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:10174>)

出口：FINISHED → Fly。isSequence=0。

1. `SetGravity2dScale(gameObject="Self", gravityScale=0)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Fly Antic", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `DecelerateXY(gameObject="Self", decelerationX="None", decelerationY=0.85, brakeOnExit=true)`



#### Fly Dir · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:10301>)

出口：L → Fly L；R → Fly R。isSequence=0。

1. `CheckXPosition(gameObject="Self", compareTo="$Centre X", compareToOffset=0, tolerance=0, equal="R", equalBool="None", lessThan="R", lessThanBool="None", greaterThan="L", greaterThanBool="None", everyFrame=false, space=0, activeBool="None")`



#### Fly L · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:10439>)

出口：FINISHED → Jump Attack 1。isSequence=0。

1. `SetScale(gameObject="Self", vector="None", x=-1.1, y="None", z="None", everyFrame=false, lateUpdate=false)`



#### Fly R · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:10541>)

出口：FINISHED → Jump Attack 1。isSequence=0。

1. `SetScale(gameObject="Self", vector="None", x=1.1, y="None", z="None", everyFrame=false, lateUpdate=false)`



#### Fly · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:10643>)

出口：FINISHED → Jump Attack 2。isSequence=0。

1. `AudioPlaySimple(gameObject="Owner($Fly Loop)", volume=1, oneShotClip="fileID:0")`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Fly")`

3. `WaitRandom(timeMin=0.75, timeMax=1.1, finishEvent="FINISHED", realTime=false)`

4. `SetVelocityByScale(gameObject="Self", speed=15, ySpeed=-1, everyFrame=false)`

5. `RayCast2dV2(fromGameObject="Owner($Ray Pt Centre)", fromPosition="None", direction={"x":1,"y":0}, space=1, distance=6, minDepth="None", maxDepth="None", hitEvent="FINISHED", noHitEvent=null, storeDidHit="None", storeHitObject="None", storeHitPoint="None", storeHitNormal="None", storeHitDistance="None", storeDistance="None", repeatInterval=1, layerMask=[8], invertMask=0, ignoreTriggers=0, debugColor={"r":1,"g":0.92156863,"b":0.015686275,"a":1}, debug=1)`



#### Drop Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:10937>)

出口：FINISHED → Drop。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Drop Antic", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `DecelerateXY(gameObject="Self", decelerationX=0.85, decelerationY=0.85, brakeOnExit=false)`

3. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:0e0686f9ecd22fb45a43c145e0ea3893#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Drop · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:11105>)

出口：LAND → Drop Land。isSequence=0。

1. `SetGravity2dScale(gameObject="Self", gravityScale=1)`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Fall")`

3. `SetVelocity2d(gameObject="Self", vector="None", x="None", y=-10, everyFrame=false)`

4. `CheckCollisionSide(collidingObject="Self", topHit="None", rightHit="None", bottomHit="None", leftHit="None", topHitEvent=null, rightHitEvent=null, bottomHitEvent="LAND", leftHitEvent=null, otherLayer=false, otherLayerNumber=0, ignoreTriggers=0)`

5. `CheckCollisionSideEnter(topHit="None", rightHit="None", bottomHit="None", leftHit="None", topHitEvent=null, rightHitEvent=null, bottomHitEvent="LAND", leftHitEvent=null, otherLayer=false, otherLayerNumber=0, ignoreTriggers=0)`



#### Drop Land · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:11345>)

出口：FINISHED → Quick Idle。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Land", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `SetVelocity2d(gameObject="Self", vector={"x":0,"y":0}, x="None", y="None", everyFrame=false)`

3. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

4. `PlayParticleEmitter(gameObject="Owner($Pt Land)", emit=0, resetIfPlaying=true)`

5. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:7930b85c540bf474581e7fda7871306b#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Jump Attack 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:11575>)

出口：TORNADO → Tornado Antic；BOMB THROW → Air Throw Antic；FINISHED → Fly Antic。isSequence=0。

1. `SetGravity2dScale(gameObject="Self", gravityScale=0)`

2. `SendRandomEventV4(events=["FINISHED","BOMB THROW","TORNADO"], weights=[0.75,0.125,0.125], eventMax=[2,1,1], missedMax=[1,6,6], activeBool="None")`



#### Jump Attack 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:11758>)

出口：TORNADO → Tornado Antic；BOMB THROW → Air Throw Antic；FINISHED → Drop Antic；DAZZLE FLASH → Flash Start Air。isSequence=0。

1. `AudioStop(gameObject="Owner($Fly Loop)", fadeTime=0)`

2. **disabled** `SendEvent(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="DAZZLE FLASH", delay=0, everyFrame=false)`

3. `SendRandomEventV4(events=["DAZZLE FLASH","BOMB THROW","TORNADO"], weights=[0.1,0.1,0.1], eventMax=[1,1,1], missedMax=[4,3,3], activeBool="$Phase 2")`

4. `SendRandomEventV4(events=["FINISHED","BOMB THROW","TORNADO","DAZZLE FLASH"], weights=[0.75,0.125,0.125,0.2], eventMax=[1,1,1,1], missedMax=[1,5,5,5], activeBool="None")`



#### Air Throw Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:12104>)

出口：FINISHED → Throw。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Attack Throw Air", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`

2. `DecelerateV2(gameObject="Self", deceleration=0.835, brakeOnExit=false)`

3. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

4. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:6de4b2fc7cb238e4780b915dfb3a086c#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

5. `AudioPlayRandomVoiceFromTable(gameObject="Self", audioClipTable="GUID:00245b57a4ba4ec4681a896947d10a28#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`



#### Fall? · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:12323>)

出口：LAND → Throw Idle；FINISHED → Drop Antic。isSequence=0。

1. `RayCast2dV2(fromGameObject="Owner($Ray Pt Centre)", fromPosition="None", direction={"x":0,"y":-1}, space=1, distance=4, minDepth="None", maxDepth="None", hitEvent="LAND", noHitEvent=null, storeDidHit="None", storeHitObject="None", storeHitPoint="None", storeHitNormal="None", storeHitDistance="None", storeDistance="None", repeatInterval=0, layerMask=[8], invertMask=0, ignoreTriggers=0, debugColor={"r":1,"g":0.92156863,"b":0.015686275,"a":1}, debug=1)`



#### Exit Pause · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:12530>)

出口：FINISHED → Get Entry Point；BURST COLUMNS → BC Pause。isSequence=0。

1. `SetVelocity2d(gameObject="Self", vector="None", x=0, y=0, everyFrame=false)`

2. `SetMeshRenderer(gameObject="Self", active=0)`

3. `SetPosition(gameObject="Self", vector="None", x="None", y=11.3, z="None", space=0, everyFrame=false, lateUpdate=false)`

4. `Wait(time=0.3, finishEvent="FINISHED", realTime=false)`

5. `GetPosition(gameObject="Self", vector="None", x="$X Pos Current", y="None", z="None", space=0, everyFrame=false)`

6. `SetIntValue(intVariable="$Retry", intValue=0, everyFrame=false)`

7. `BoolTest(boolVariable="$Will Burst Column", isTrue="BURST COLUMNS", isFalse=null, everyFrame=false)`



#### Get Entry Point · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:12777>)

出口：RETRY → Retry；FINISHED → Bomb Flurry?。isSequence=0。

1. `RandomFloat(min=61.5, max=86.3, storeResult="$X Pos Target")`

2. `GetDifferenceBetweenFloats(differenceResult="$Difference", float1="$X Pos Current", float2="$X Pos Target", everyFrame=false)`

3. `FloatCompare(float1="$Difference", float2=10, tolerance=0, equal=null, lessThan="RETRY", greaterThan=null, everyFrame=false)`



#### Retry · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:12924>)

出口：RETRY FRAME → Retry Frame；FINISHED → Get Entry Point。isSequence=0。

1. `IntAdd(intVariable="$Retry", add=1, everyFrame=false)`

2. `IntCompare(integer1="$Retry", integer2=998, equal="RETRY FRAME", lessThan=null, greaterThan="RETRY FRAME", everyFrame=false)`



#### Retry Frame · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:13034>)

出口：FINISHED → Get Entry Point。isSequence=0。

1. `SetIntValue(intVariable="$Retry", intValue=0, everyFrame=false)`

2. `NextFrameEvent(sendEvent="FINISHED")`



#### Move Dir · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:13116>)

出口：L → Move L；R → Move R。isSequence=0。

1. `FloatCompare(float1="$X Pos Current", float2="$X Pos Target", tolerance=0, equal=null, lessThan="R", greaterThan="L", everyFrame=false)`



#### Move L · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:13216>)

出口：END → Enter Pause。isSequence=0。

1. `SetVelocity2d(gameObject="Self", vector="None", x=-19, y=0, everyFrame=false)`

2. `ActivateGameObjectDelay(gameObject="Owner($Floor Bouncer)", activate=1, resetOnExit=true, delay=0.1)`

3. `CheckXPosition(gameObject="Self", compareTo="$X Pos Target", compareToOffset=0, tolerance=0, equal="END", equalBool="None", lessThan="END", lessThanBool="None", greaterThan=null, greaterThanBool="None", everyFrame=true, space=0, activeBool="None")`



#### Move R · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:13404>)

出口：END → Enter Pause。isSequence=0。

1. `SetVelocity2d(gameObject="Self", vector="None", x=19, y=0, everyFrame=false)`

2. `ActivateGameObjectDelay(gameObject="Owner($Floor Bouncer)", activate=1, resetOnExit=true, delay=0.1)`

3. `CheckXPosition(gameObject="Self", compareTo="$X Pos Target", compareToOffset=0, tolerance=0, equal="END", equalBool="None", lessThan=null, lessThanBool="None", greaterThan="END", greaterThanBool="None", everyFrame=true, space=0, activeBool="None")`



#### Enter Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:13592>)

出口：FINISHED → Enter 1。isSequence=0。

1. `Wait(time=0.4, finishEvent="FINISHED", realTime=false)`

2. `PlayParticleEmitterInState(gameObject="Owner($Pt Entry Antic)")`

3. `AudioPlayInState(gameObject="Owner($Smoke Trapdoor Loop)", volume=1)`



#### Enter 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:13694>)

出口：FINISHED → Enter Jump?。isSequence=0。

1. `SetVelocity2d(gameObject="Self", vector="None", x=0, y=0, everyFrame=false)`

2. `SetRecoilBlocked(Target="Self", IsUpBlocked=0, IsDownBlocked=0, IsLeftBlocked=0, IsRightBlocked=0)`

3. `SetPositionToObject(gameObject="Owner($Trapdoor L)", targetObject="$Self", xOffset=-0.86, yOffset=-2.93, zOffset=-0.001, overrideZ="None", everyFrame=false)`

4. `AudioPlayRandomVoiceFromTable(gameObject="Self", audioClipTable="GUID:00245b57a4ba4ec4681a896947d10a28#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`

5. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:b9b13487d0a3f0742b19eb6b46b41878#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

6. `SetPositionToObject(gameObject="Owner($Trapdoor R)", targetObject="$Self", xOffset=1.06, yOffset=-2.93, zOffset=-0.001, overrideZ="None", everyFrame=false)`

7. `ActivateGameObject(gameObject="Owner($Trapdoor R)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

8. `ActivateGameObject(gameObject="Owner($Trapdoor L)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

9. `PlayParticleEmitter(gameObject="Owner($Pt Exit)", emit=0, resetIfPlaying=false)`

10. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

11. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Enter", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`

12. `SetInvincible(target="Self", Invincible=0, InvincibleFromDirection=0, resetOnStateExit=false)`

13. `SetMeshRenderer(gameObject="Self", active=1)`

14. `DoCameraShake(VisibleRenderer="Owner(fileID:0)", Camera="GUID:9b0888e0916dca544846a2f34304dac9#11400000", Profile="GUID:279f38013a080f34999cd00fbee1b9c2#11400000", cancelOnExit=false, DoFreeze=0, Delay=0)`

15. `SetRecoilSpeed(target="Self", newRecoilSpeed=0)`



#### Enter 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:14237>)

出口：FINISHED → Enter End。isSequence=0。

1. `Tk2dWatchAnimationEvents(gameObject="Self", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:7930b85c540bf474581e7fda7871306b#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Enter Pause · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:14372>)

出口：FINISHED → Enter Antic。isSequence=0。

1. `SetVelocity2d(gameObject="Self", vector="None", x=0, y=0, everyFrame=false)`

2. `Wait(time=0.1, finishEvent="FINISHED", realTime=false)`

3. `SetPosition(gameObject="Self", vector="None", x="$X Pos Target", y="$Floor Y", z="None", space=0, everyFrame=false, lateUpdate=false)`



#### Enter End · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:14520>)

出口：FINISHED → Pose Idle。isSequence=0。

1. `SetRecoilSpeed(target="Self", newRecoilSpeed=15)`



#### Enter Jump? · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:14599>)

出口：FINISHED → Enter 2；JUMP → Jump。isSequence=0。

1. `PlayParticleEmitter(gameObject="Owner($Pt IdleGlitter)", emit=0, resetIfPlaying=false)`

2. `SetIsKinematic2d(gameObject="Self", isKinematic=0)`

3. `SetCollider(gameObject="Self", active=1, resetOnExit=false)`

4. `ActivateGameObject(gameObject="Owner($Damage Collider)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

5. `BoolTest(boolVariable="$Will Burst Column", isTrue="JUMP", isFalse=null, everyFrame=false)`

6. `SendRandomEventV4(events=["JUMP","FINISHED"], weights=[1,1], eventMax=[2,2], missedMax=[2,2], activeBool="None")`



#### Quick Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:14829>)

出口：FINISHED → Evade?。isSequence=0。

1. `Wait(time=0.2, finishEvent="FINISHED", realTime=false)`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Idle")`



#### Rethrow? · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:14927>)

出口：FINISHED → Pose?；BOMB THROW → Throw Antic。isSequence=0。

1. `SendRandomEventV4(events=["FINISHED","BOMB THROW"], weights=[0.66,0.33], eventMax=[2,1], missedMax=[1,2], activeBool="None")`



#### Bomb Flurry? · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:15060>)

出口：FINISHED → Move Dir；BOMB THROW → Move Dir 2。isSequence=0。

1. **disabled** `SendEvent(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="BOMB THROW", delay=0, everyFrame=false)`

2. `GetDifferenceBetweenFloats(differenceResult="$Difference", float1="$X Pos Current", float2="$Centre X", everyFrame=false)`

3. `FloatCompare(float1="$Difference", float2=6, tolerance=0, equal="FINISHED", lessThan=null, greaterThan=null, everyFrame=false)`

4. `SendRandomEventV4(events=["BOMB THROW","FINISHED"], weights=[0.5,1], eventMax=[1,3], missedMax=[3,1], activeBool="None")`



#### Move Dir 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:15292>)

出口：L → Move L 2；R → Move R 2。isSequence=0。

1. `FloatCompare(float1="$X Pos Current", float2="$Centre X", tolerance=0, equal=null, lessThan="R", greaterThan="L", everyFrame=false)`



#### Move L 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:15392>)

出口：END → Flurry Pause。isSequence=0。

1. `SetVelocity2d(gameObject="Self", vector="None", x=-17, y=0, everyFrame=false)`

2. `ActivateGameObjectDelay(gameObject="Owner($Floor Bouncer)", activate=1, resetOnExit=true, delay=0.1)`

3. `CheckXPosition(gameObject="Self", compareTo="$Centre X", compareToOffset=0, tolerance=0, equal="END", equalBool="None", lessThan="END", lessThanBool="None", greaterThan=null, greaterThanBool="None", everyFrame=true, space=0, activeBool="None")`



#### Move R 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:15580>)

出口：END → Flurry Pause。isSequence=0。

1. `SetVelocity2d(gameObject="Self", vector="None", x=17, y=0, everyFrame=false)`

2. `ActivateGameObjectDelay(gameObject="Owner($Floor Bouncer)", activate=1, resetOnExit=true, delay=0.1)`

3. `CheckXPosition(gameObject="Self", compareTo="$Centre X", compareToOffset=0, tolerance=0, equal="END", equalBool="None", lessThan=null, lessThanBool="None", greaterThan="END", greaterThanBool="None", everyFrame=true, space=0, activeBool="None")`



#### Flurry Pause · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:15768>)

出口：FINISHED → Flurry Antic。isSequence=0。

1. `SetVelocity2d(gameObject="Self", vector="None", x=0, y=0, everyFrame=false)`

2. `Wait(time=0.15, finishEvent="FINISHED", realTime=false)`

3. `SetPosition(gameObject="Self", vector="None", x="$Centre X", y="$Floor Y", z="None", space=0, everyFrame=false, lateUpdate=false)`



#### Flurry Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:15916>)

出口：FINISHED → Flurry Bombs。isSequence=0。

1. `Wait(time=0.75, finishEvent="FINISHED", realTime=false)`

2. `PlayParticleEmitterInState(gameObject="Owner($Pt Entry Antic)")`

3. `AudioPlayInState(gameObject="Owner($Smoke Trapdoor Loop)", volume=1)`



#### Flurry Shot · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:16018>)

出口：FINISHED → Keep Moving。isSequence=0。

1. `SetPositionToObject(gameObject="Owner($Trapdoor L)", targetObject="$Self", xOffset=-0.86, yOffset=-2.93, zOffset=-0.001, overrideZ="None", everyFrame=false)`

2. `SetPositionToObject(gameObject="Owner($Trapdoor R)", targetObject="$Self", xOffset=1.06, yOffset=-2.93, zOffset=-0.001, overrideZ="None", everyFrame=false)`

3. `ActivateGameObject(gameObject="Owner($Trapdoor R)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

4. `ActivateGameObject(gameObject="Owner($Trapdoor L)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

5. `PlayParticleEmitter(gameObject="Owner($Pt Exit)", emit=0, resetIfPlaying=false)`

6. `DoCameraShake(VisibleRenderer="Owner(fileID:0)", Camera="GUID:9b0888e0916dca544846a2f34304dac9#11400000", Profile="GUID:279f38013a080f34999cd00fbee1b9c2#11400000", cancelOnExit=false, DoFreeze=0, Delay=0)`

7. `Wait(time=1.9, finishEvent="FINISHED", realTime=false)`



#### Keep Moving · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:16300>)

出口：FINISHED → Move Dir。isSequence=0。

1. `SetPosition(gameObject="Self", vector="None", x="None", y=11.3, z="None", space=0, everyFrame=false, lateUpdate=false)`

2. `GetPosition(gameObject="Self", vector="None", x="$X Pos Current", y="None", z="None", space=0, everyFrame=false)`

3. `RandomFloatEither(value1=-10, value2=10, storeResult="$X Pos Target")`

4. `FloatAdd(floatVariable="$X Pos Target", add="$Centre X", everyFrame=false, perSecond=false)`



#### Flurry Bombs · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:16485>)

出口：FINISHED → Flurry Shot。isSequence=0。

1. `RandomFloatEither(value1=0, value2=90, storeResult="$Bomb Rotation")`

2. `AudioPlayRandomVoiceFromTable(gameObject="Self", audioClipTable="GUID:a4fd2c9fc694d844492a16e3e1f5c595#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`

3. `SetFloatValue(floatVariable="$Target Y", floatValue="$Max Y", everyFrame=false)`

4. `GetPosition(gameObject="Owner($Throw Point)", vector="$Throw Point Vector", x="None", y="$Current Y", z="None", space=0, everyFrame=false)`

5. `FloatSubtract(floatVariable="$Target Y", subtract="$Current Y", everyFrame=false, perSecond=false)`

6. `SetFloatToLowest(floatVariable="$Target Y", value1="$Target Y", value2=0, everyFrame=false)`

7. `FloatSubtract(floatVariable="$Target Y", subtract=1, everyFrame=false, perSecond=false)`

8. `SetVector3XYZ(vector3Variable="$Throw Point Vector", vector3Value="None", x=0.5, y="$Target Y", z="None", everyFrame=false)`

9. `SpawnObjectFromGlobalPool(gameObject="GUID:04bfbcef4b02e2e4b9fb18f9d0b7a165#1709254077376921", spawnPoint="$Throw Point", position="$Throw Point Vector", rotation="None", storeObject="$Projectile")`

10. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:b9b13487d0a3f0742b19eb6b46b41878#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

11. `SetFsmFloat(gameObject="Owner($Projectile)", fsmName="Control", variableName="X Velocity", setValue=15, everyFrame=false)`

12. `SetVelocity2d(gameObject="Owner($Projectile)", vector="None", x=15, y="None", everyFrame=false)`

13. `SetFsmFloat(gameObject="Owner($Projectile)", fsmName="Control", variableName="Rotation", setValue="$Bomb Rotation", everyFrame=false)`

14. `FloatAdd(floatVariable="$Bomb Rotation", add=90, everyFrame=false, perSecond=false)`

15. `SetVector3XYZ(vector3Variable="$Throw Point Vector", vector3Value="None", x=0, y="None", z="None", everyFrame=false)`

16. `SpawnObjectFromGlobalPool(gameObject="GUID:04bfbcef4b02e2e4b9fb18f9d0b7a165#1709254077376921", spawnPoint="$Throw Point", position="$Throw Point Vector", rotation="None", storeObject="$Projectile")`

17. `SetFsmFloat(gameObject="Owner($Projectile)", fsmName="Control", variableName="X Velocity", setValue=0, everyFrame=false)`

18. `SetVelocity2d(gameObject="Owner($Projectile)", vector="None", x=0, y="None", everyFrame=false)`

19. `SetFsmFloat(gameObject="Owner($Projectile)", fsmName="Control", variableName="Rotation", setValue="$Bomb Rotation", everyFrame=false)`

20. `FloatAdd(floatVariable="$Bomb Rotation", add=90, everyFrame=false, perSecond=false)`

21. `SetVector3XYZ(vector3Variable="$Throw Point Vector", vector3Value="None", x=-0.5, y="None", z="None", everyFrame=false)`

22. `SpawnObjectFromGlobalPool(gameObject="GUID:04bfbcef4b02e2e4b9fb18f9d0b7a165#1709254077376921", spawnPoint="$Throw Point", position="$Throw Point Vector", rotation="None", storeObject="$Projectile")`

23. `SetFsmFloat(gameObject="Owner($Projectile)", fsmName="Control", variableName="X Velocity", setValue=-15, everyFrame=false)`

24. `SetVelocity2d(gameObject="Owner($Projectile)", vector="None", x=-15, y="None", everyFrame=false)`

25. `SetFsmFloat(gameObject="Owner($Projectile)", fsmName="Control", variableName="Rotation", setValue="$Bomb Rotation", everyFrame=false)`

26. `FloatAdd(floatVariable="$Bomb Rotation", add=90, everyFrame=false, perSecond=false)`



#### Stun Start · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:17344>)

出口：FINISHED → Stun Air。isSequence=0。

1. `GetPosition2d(gameObject="Self", vector_2d="None", x="None", y="$Current Y", space=0, everyFrame=false)`

2. `FloatClamp(floatVariable="$Current Y", minValue=16.91, maxValue=99999, everyFrame=false)`

3. `SetPosition2d(gameObject="Self", vector="None", x="None", y="$Current Y", space=0, everyFrame=false, lateUpdate=false)`

4. `SetBoolValue(boolVariable="$Doing First Attack", boolValue=0, everyFrame=false)`

5. `SetRecoilBlocked(Target="Self", IsUpBlocked=0, IsDownBlocked=0, IsLeftBlocked=0, IsRightBlocked=0)`

6. `SetRecoilSpeed(target="Self", newRecoilSpeed=12)`

7. `AudioPlayRandomVoiceFromTable(gameObject="Self", audioClipTable="GUID:f1b2c5e154722ad439ea2c92b9364df8#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`

8. `ScreenFlashTrobbio()`

9. `SetFloatValue(floatVariable="$Stun Timer", floatValue=2, everyFrame=false)`

10. `SetGravity2dScale(gameObject="Self", gravityScale=1)`

11. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

12. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Stun Air")`

13. `SetBoolValue(boolVariable="$Doing First Burst Column", boolValue=0, everyFrame=false)`

14. `SetVelocityByScale(gameObject="Self", speed=-6, ySpeed=20, everyFrame=false)`

15. `NextFrameEvent(sendEvent="FINISHED")`

16. `ActivateGameObject(gameObject="Owner($Tornado Damager)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

17. `ActivateGameObject(gameObject="Owner($Tornado Event Sender)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

18. `ActivateGameObject(gameObject="Owner($Damage Collider)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

19. `StopParticleEmittersInChildren(gameObject="Owner($Pt Tornado Dust)")`

20. `PlayParticleEmitter(gameObject="Owner($Pt Stun)", emit=0, resetIfPlaying=false)`

21. `AudioStop(gameObject="Owner($Tornado Loop)", fadeTime=0)`

22. `AudioStop(gameObject="Owner($Fly Loop)", fadeTime=0)`

23. `SetBoolValue(boolVariable="$Will Burst Column", boolValue=0, everyFrame=false)`

24. `SetInvincible(target="Self", Invincible=0, InvincibleFromDirection=13, resetOnStateExit=false)`

25. `SetDamageHero(Target="Self", Enabled=0)`

26. `SetMeshRenderer(gameObject="Self", active=1)`

27. `SetIsKinematic2d(gameObject="Self", isKinematic=0)`

28. `SetCollider(gameObject="Self", active=1, resetOnExit=false)`



#### Stun Air · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:18002>)

出口：LAND → Stun Land。isSequence=0。

1. `CheckCollisionSideEnter(topHit="None", rightHit="None", bottomHit="None", leftHit="None", topHitEvent=null, rightHitEvent=null, bottomHitEvent="LAND", leftHitEvent=null, otherLayer=false, otherLayerNumber=0, ignoreTriggers=0)`

2. `CheckCollisionSide(collidingObject="Self", topHit="None", rightHit="None", bottomHit="None", leftHit="None", topHitEvent=null, rightHitEvent=null, bottomHitEvent="LAND", leftHitEvent=null, otherLayer=false, otherLayerNumber=0, ignoreTriggers=0)`

3. `ActivateGameObject(gameObject="Owner(fileID:1841364053301648)", activate=1, recursive=0, resetOnExit=true, everyFrame=false)`



#### Stunned · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:18193>)

出口：END → Stun Recover；TOOK DAMAGE → Stun Damage。isSequence=0。

1. `DecelerateXY(gameObject="Self", decelerationX=0.85, decelerationY="None", brakeOnExit=false)`

2. `FloatAdd(floatVariable="$Stun Timer", add=-1, everyFrame=true, perSecond=true)`

3. `FloatCompare(float1="$Stun Timer", float2=0, tolerance=0, equal="END", lessThan="END", greaterThan=null, everyFrame=true)`

4. `AudioPlayInState(gameObject="Owner(fileID:1518489005915545)", volume=0)`

5. `FadeAudio(gameObject="Owner(fileID:1518489005915545)", startVolume=0, endVolume=1, time=0.75)`



#### Stun Recover · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:18387>)

出口：FINISHED → Quick Idle。isSequence=0。

1. `SetRecoilSpeed(target="Self", newRecoilSpeed=15)`

2. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="STUN CONTROL START", delay=0, everyFrame=false)`

3. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Stun Recover", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

4. `SetRecoilSpeed(target="Self", newRecoilSpeed=12)`

5. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:0e0686f9ecd22fb45a43c145e0ea3893#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Stun Land · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:18615>)

出口：FINISHED → Stunned。isSequence=0。

1. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Stun Land")`

2. `SetVelocity2d(gameObject="Self", vector="None", x=0, y=0, everyFrame=false)`

3. `SetDamageHero(Target="Self", Enabled=1)`

4. `PlayParticleEmitter(gameObject="Owner($Pt Land)", emit=0, resetIfPlaying=false)`

5. `ActivateGameObject(gameObject="Owner($Damage Collider)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

6. `SetRecoilSpeed(target="Self", newRecoilSpeed=5)`

7. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:7930b85c540bf474581e7fda7871306b#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Stun Damage · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:18875>)

出口：FINISHED → Stunned；END → Damage Recover。isSequence=0。

1. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

2. `AudioPlayRandomVoiceFromTable(gameObject="Self", audioClipTable="GUID:f1b2c5e154722ad439ea2c92b9364df8#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`

3. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Stun Hit")`

4. `Tk2dPlayFrame(gameObject="Self", frame=0)`

5. `FloatAdd(floatVariable="$Stun Timer", add=-0.25, everyFrame=false, perSecond=false)`

6. `FloatCompare(float1="$Stun Timer", float2=0, tolerance=0, equal="END", lessThan="END", greaterThan="FINISHED", everyFrame=false)`



#### Damage Recover · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:19094>)

出口：FINISHED → Stun Recover。isSequence=0。

1. `SendMessage(gameObject="Owner($GameManager)", delivery=0, options=1, functionCall={"FunctionName":"FreezeMoment","parameterType":"int","BoolParameter":0,"FloatParameter":0,"IntParameter":1,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`

2. `SendEventByName(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="EnemyKillShake", delay=0, everyFrame=false)`



#### Wait Refight · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:19342>)

出口：ENTER → Start Pause。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=0)`

2. `Trigger2dEvent(gameObject="Owner($Start Range)", trigger=0, collideTag=null, sendEvent="ENTER", storeCollider="None")`



#### Start Pause · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:19449>)

出口：FINISHED → Spotlight Scan；REFIGHT → Quick Entrance 1。isSequence=0。

1. `Wait(time=1, finishEvent="FINISHED", realTime=false)`

2. `SendEventToRegister(eventName="TENSION END")`

3. `ActivateGameObject(gameObject="Owner($CamLock Intro)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

4. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Gates)","fsmName":null,"sendToChildren":1,"fsmComponent":"fileID:0"}, sendEvent="BG CLOSE", delay=0, everyFrame=false)`

5. `PlayerDataBoolTest(boolName="encounteredTrobbio", isTrue="REFIGHT", isFalse=null)`



#### Spotlight Scan · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:19630>)

出口：FINISHED → Jets。isSequence=0。

1. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Spotlight L)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="SCAN", delay=0, everyFrame=false)`

2. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Spotlight R)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="SCAN", delay=0, everyFrame=false)`

3. `Wait(time=2.5, finishEvent="FINISHED", realTime=false)`

4. `AudioPlaySimple(gameObject="Owner($Drum Loop)", volume=1, oneShotClip="fileID:0")`



#### Appear Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:19829>)

出口：FINISHED → Appear 1。isSequence=0。

1. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Spotlight L)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="FOLLOW", delay=0, everyFrame=false)`

2. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Spotlight R)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="FOLLOW", delay=0, everyFrame=false)`

3. `Wait(time=1, finishEvent="FINISHED", realTime=false)`

4. `PlayParticleEmitterInState(gameObject="Owner($Pt Intro Steam)")`



#### Jets · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:20013>)

出口：FINISHED → Appear Antic。isSequence=0。

1. `PlayParticleEmitterChildren(gameObject="Owner($Steam Jets)", resetTimeIfPlaying=true, stopOnStateExit=false)`

2. `Wait(time=2, finishEvent="FINISHED", realTime=false)`

3. `AudioPlaySimple(gameObject="Owner($Smoke Loop)", volume=1, oneShotClip="fileID:0")`

4. `PlayParticleEmitterInState(gameObject="Owner($Pt Intro Steam)")`



#### Appear 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:20136>)

出口：FINISHED → Appear Rise。isSequence=0。

1. `FadeAudio(gameObject="Owner($Smoke Loop)", startVolume=1, endVolume=0, time=0.25)`

2. `SendEventToRegister(eventName="TENSION END")`

3. `FadeAudio(gameObject="Owner($Drum Loop)", startVolume=1, endVolume=0, time=0.25)`

4. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:9edc4820c94536845964fb16515538f7#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

5. `StopParticleEmittersInChildren(gameObject="Owner($Steam Jets)")`

6. `PlayParticleEmitterChildren(gameObject="Owner($Confetti Shooters)", resetTimeIfPlaying=true, stopOnStateExit=false)`

7. `SetPositionToObject(gameObject="Owner($Trapdoor L)", targetObject="$Self", xOffset=-0.86, yOffset=-2.93, zOffset=-0.001, overrideZ="None", everyFrame=false)`

8. `SetPositionToObject(gameObject="Owner($Trapdoor R)", targetObject="$Self", xOffset=1.06, yOffset=-2.93, zOffset=-0.001, overrideZ="None", everyFrame=false)`

9. `ActivateGameObject(gameObject="Owner($Trapdoor R)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

10. `ActivateGameObject(gameObject="Owner($Trapdoor L)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

11. `PlayParticleEmitter(gameObject="Owner($Pt Exit)", emit=0, resetIfPlaying=false)`

12. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

13. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Enter", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`

14. `SetMeshRenderer(gameObject="Self", active=1)`

15. `DoCameraShake(VisibleRenderer="Owner(fileID:0)", Camera="GUID:9b0888e0916dca544846a2f34304dac9#11400000", Profile="GUID:279f38013a080f34999cd00fbee1b9c2#11400000", cancelOnExit=false, DoFreeze=0, Delay=0)`



#### Appear Rise · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:20638>)

出口：FINISHED → Appear Burst。isSequence=0。

1. `AudioPlaySimple(gameObject="Self", volume=1, oneShotClip="GUID:2babf06b1ab8a6c4999ad1339f46fe2b#8300000")`

2. `PlayParticleEmitter(gameObject="Owner($Pt IdleGlitter)", emit=0, resetIfPlaying=false)`

3. `SetIsKinematic2d(gameObject="Self", isKinematic=0)`

4. `SetCollider(gameObject="Self", active=1, resetOnExit=false)`

5. `ActivateGameObject(gameObject="Owner($Damage Collider)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

6. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Flash Attack Intro", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`

7. `SetGravity2dScale(gameObject="Self", gravityScale=0)`

8. `SetVelocity2d(gameObject="Self", vector="None", x="None", y=40, everyFrame=false)`

9. `DecelerateV2(gameObject="Self", deceleration=0.825, brakeOnExit=false)`



#### Appear Burst · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:20900>)

出口：FINISHED → Fall 2。isSequence=0。

1. `Tk2dWatchAnimationEvents(gameObject="Self", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `DecelerateV2(gameObject="Self", deceleration=0.825, brakeOnExit=false)`

3. `ActivateGameObject(gameObject="Owner($Dazzle Flash)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

4. `ScreenFlashTrobbio()`

5. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Flare Glitter)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="FLARE GLITTER INTRO", delay=0, everyFrame=false)`

6. `DisplayBossTitle(areaTitleObject="$AreaTitle", displayRight=0, bossTitle="TROBBIO")`

7. `ApplyMusicCue(musicCue="GUID:eae756ca2b97202419cfcf2ea90833bb#11400000", delayTime=0, transitionTime=0)`

8. `TransitionToAudioSnapshot(snapshot="GUID:1e5b83863824c3e46b1a27345f960db5#24500036", transitionTime=0.1)`

9. `SetPlayerDataBool(boolName="encounteredTrobbio", value=1)`



#### Land 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:21154>)

出口：FINISHED → Start Idle。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Land", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `SetVelocity2d(gameObject="Self", vector={"x":0,"y":0}, x="None", y="None", everyFrame=false)`

3. `PlayParticleEmitter(gameObject="Owner($Pt Land)", emit=0, resetIfPlaying=true)`

4. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:7930b85c540bf474581e7fda7871306b#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Fall 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:21348>)

出口：LAND → Land 2。isSequence=0。

1. `SetGravity2dScale(gameObject="Self", gravityScale=1)`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Fall")`

3. `CheckCollisionSide(collidingObject="Self", topHit="None", rightHit="None", bottomHit="None", leftHit="None", topHitEvent=null, rightHitEvent=null, bottomHitEvent="LAND", leftHitEvent=null, otherLayer=false, otherLayerNumber=0, ignoreTriggers=0)`

4. `CheckCollisionSideEnter(topHit="None", rightHit="None", bottomHit="None", leftHit="None", topHitEvent=null, rightHitEvent=null, bottomHitEvent="LAND", leftHitEvent=null, otherLayer=false, otherLayerNumber=0, ignoreTriggers=0)`

5. `ActivateGameObject(gameObject="Owner($CamLock Intro)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

6. `ActivateGameObject(gameObject="Owner($CamLock Boss)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`



#### Start Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:21609>)

出口：FINISHED → Pose Set；TOOK DAMAGE → Pose Set；EVADE → Tornado Evade。isSequence=0。

1. `Wait(time=1, finishEvent="FINISHED", realTime=false)`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Idle")`

3. `PreventInvincibleEffect(target="Self", preventEffect=0)`

4. `CheckAlertRangeByName(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, alertRangeName="Evade Range", storeResult="$In Evade Range", sendEvent=null, outOfRangeEvent=null, everyFrame=true)`

5. `SetBoolValueAtTime(BoolVariable="$Can Evade", BoolValue=1, Time=0.5, SetOppositeOnStateEntry=true)`

6. `BoolAllTrue(boolVariables=["$Can Evade","$In Evade Range"], sendEvent="EVADE", storeResult="None", everyFrame=true)`



#### Death Hit · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:21854>)

出口：FINISHED → Death Fling。isSequence=0。

1. `SetIsKinematic2d(gameObject="Self", isKinematic=0)`

2. `SetCollider(gameObject="Self", active=1, resetOnExit=false)`

3. `RecordJournalKill(Record="GUID:2ca30dc46dc7c1147ac923f91c7b2efa#11400000")`

4. `SetPlayerDataBool(boolName="defeatedTrobbio", value=1)`

5. `QueueAchievement(Key="DEFEATED_TROBBIO")`

6. `PreventInvincibleEffect(target="Self", preventEffect=1)`

7. `AudioStop(gameObject="Owner($Fly Loop)", fadeTime=0)`

8. `AudioStop(gameObject="Owner($Tornado Loop)", fadeTime=0)`

9. `AudioStop(gameObject="Self", fadeTime=0)`

10. `AudioPlaySimple(gameObject="Self", volume=1, oneShotClip="GUID:0e46f04046446e340b0fbc984715fc9a#8300000")`

11. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="STUN CONTROL START", delay=0, everyFrame=false)`

12. `SetGravity2dScale(gameObject="Self", gravityScale=0)`

13. `ScreenFlashTrobbio()`

14. `SetVelocity2d(gameObject="Self", vector={"x":0,"y":0}, x="None", y="None", everyFrame=false)`

15. `StopParticleEmittersInChildren(gameObject="Owner($Pt Tornado Dust)")`

16. `PlayParticleEmitter(gameObject="Owner($Pt Stun)", emit=0, resetIfPlaying=false)`

17. `SendEventToRegister(eventName="TROBBIO KILLED")`

18. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

19. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Stun Air")`

20. `CreateObject(gameObject="GUID:be12682da8276094b8fcdc2162ff8ddd#1709254077376921", spawnPoint="$Self", position="None", rotation="None", storeObject="None")`

21. **disabled** `ActivateGameObject(gameObject="Owner($Kill Hit)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

22. `PlayParticleEmitter(gameObject="Owner($Pt KillHit)", emit=0, resetIfPlaying=false)`

23. `ApplyMusicCue(musicCue="GUID:3f1b10039c22ccd448ea6d4f450e94b1#11400000", delayTime=0, transitionTime=0)`

24. `TransitionToAudioSnapshot(snapshot="GUID:1e5b83863824c3e46b1a27345f960db5#24500034", transitionTime=0)`

25. `GetOwner(storeGameObject="$Self")`

26. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($CameraParent)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="BigShake", delay=0, everyFrame=false)`

27. **disabled** `SendMessage(gameObject="Owner($GameManager)", delivery=0, options=1, functionCall={"FunctionName":"FreezeMoment","parameterType":"int","BoolParameter":0,"FloatParameter":0,"IntParameter":2,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`

28. `PlayAudioEvent(audioClip="GUID:355ab94ffb2f4b14f8f63d140df84772#8300000", pitchMin=1, pitchMax=1, volume=1, audioPlayerPrefab="None", spawnPoint="Self", spawnPosition={"x":0,"y":0,"z":0}, SpawnedPlayerRef="None")`

29. `Wait(time=0.1, finishEvent="FINISHED", realTime=false)`

30. `ActivateGameObject(gameObject="Owner($Tornado Damager)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

31. `ActivateGameObject(gameObject="Owner($Tornado Event Sender)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

32. `ActivateGameObject(gameObject="Owner($Damage Collider)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

33. `CallMethodProper(gameObject="Self", behaviour="NonBouncer", methodName="SetActive", parameters=[{"variableName":null,"objectType":"UnityEngine.Object","useVariable":0,"type":2,"floatValue":0,"intValue":0,"boolValue":1,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}], storeResult={"variableName":null,"objectType":"UnityEngine.Object","useVariable":1,"type":-1,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}, EveryFrame=false)`

34. `SetInvincible(target="Self", Invincible=1, InvincibleFromDirection=0, resetOnStateExit=false)`

35. `SetLayer(gameObject="Self", layer=14)`

36. `GetPosition2d(gameObject="Self", vector_2d="None", x="None", y="$Y Pos", space=0, everyFrame=false)`

37. `FloatClamp(floatVariable="$Y Pos", minValue=16.7, maxValue=1000, everyFrame=false)`

38. `SetPosition2d(gameObject="Self", vector="None", x="None", y="$Y Pos", space=0, everyFrame=false, lateUpdate=false)`

39. `SetMeshRenderer(gameObject="Self", active=1)`



#### Death Fling · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:22990>)

出口：FINISHED → Death Air。isSequence=0。

1. `SetVelocityByScale(gameObject="Self", speed=-4, ySpeed=25, everyFrame=false)`

2. `SetGravity2dScale(gameObject="Self", gravityScale=1)`

3. `NextFrameEvent(sendEvent="FINISHED")`

4. `GetPosition2d(gameObject="Self", vector_2d="None", x="None", y="$Y Pos", space=0, everyFrame=false)`

5. `FloatClamp(floatVariable="$Y Pos", minValue=16.7, maxValue=1000, everyFrame=false)`

6. `SetPosition2d(gameObject="Self", vector="None", x="None", y="$Y Pos", space=0, everyFrame=false, lateUpdate=false)`



#### Death Air · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:23192>)

出口：LAND → Death Land；FINISHED → Death Catch。isSequence=0。

1. `CheckCollisionSideEnter(topHit="None", rightHit="None", bottomHit="None", leftHit="None", topHitEvent=null, rightHitEvent=null, bottomHitEvent="LAND", leftHitEvent=null, otherLayer=false, otherLayerNumber=0, ignoreTriggers=0)`

2. `CheckCollisionSide(collidingObject="Self", topHit="None", rightHit="None", bottomHit="None", leftHit="None", topHitEvent=null, rightHitEvent=null, bottomHitEvent="LAND", leftHitEvent=null, otherLayer=false, otherLayerNumber=0, ignoreTriggers=0)`

3. `GetPosition2d(gameObject="Self", vector_2d="None", x="None", y="$Y Pos", space=0, everyFrame=false)`

4. `FloatClamp(floatVariable="$Y Pos", minValue=16.7, maxValue=1000, everyFrame=false)`

5. `SetPosition2d(gameObject="Self", vector="None", x="None", y="$Y Pos", space=0, everyFrame=false, lateUpdate=false)`

6. `Wait(time=1, finishEvent="FINISHED", realTime=false)`



#### Death Land · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:23470>)

出口：L → Death Spin L；R → Death Spin R。isSequence=0。

1. `AudioPlaySimple(gameObject="Owner($Drum Loop)", volume=1, oneShotClip="fileID:0")`

2. `SetVelocity2d(gameObject="Self", vector="None", x=0, y=0, everyFrame=false)`

3. `PlayParticleEmitter(gameObject="Owner($Pt Land)", emit=0, resetIfPlaying=false)`

4. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Stun Land")`

5. **disabled** `Wait(time=0, finishEvent="FINISHED", realTime=false)`

6. `SendEventByScale(gameObject="Self", eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, xScale=true, positiveEvent="L", negativeEvent="R", space=0)`



#### Quick Entrance 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:23705>)

出口：FINISHED → Quick Entrance 2。isSequence=0。

1. `Wait(time=1, finishEvent="FINISHED", realTime=false)`



#### Quick Entrance 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:23778>)

出口：FINISHED → Quick Entrance 3。isSequence=0。

1. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Spotlight L)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="SCAN", delay=0, everyFrame=false)`

2. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Spotlight R)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="SCAN", delay=0, everyFrame=false)`

3. `PlayParticleEmitterChildren(gameObject="Owner($Steam Jets)", resetTimeIfPlaying=true, stopOnStateExit=false)`

4. `Wait(time=1.5, finishEvent="FINISHED", realTime=false)`

5. `AudioPlaySimple(gameObject="Owner($Drum Loop)", volume=1, oneShotClip="fileID:0")`

6. `AudioPlaySimple(gameObject="Owner($Smoke Loop)", volume=1, oneShotClip="fileID:0")`

7. `PlayParticleEmitterInState(gameObject="Owner($Pt Intro Steam)")`



#### Death Spin Centre · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:24027>)

出口：R → Death Spin R；L → Death Spin L。isSequence=0。

1. `CheckXPosition(gameObject="Self", compareTo="$Centre X", compareToOffset=0, tolerance=0, equal="L", equalBool="None", lessThan="R", lessThanBool="None", greaterThan="L", greaterThanBool="None", everyFrame=false, space=0, activeBool="None")`



#### Death Spin R · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:24165>)

出口：FINISHED → Death Spin。isSequence=0。

1. `SetScale(gameObject="Self", vector="None", x=1.1, y="None", z="None", everyFrame=false, lateUpdate=false)`

2. `SetVelocityByScale(gameObject="Self", speed=38, ySpeed="None", everyFrame=false)`



#### Death Spin · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:24293>)

出口：FINISHED → Force Centre?。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Idle Spin", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `DecelerateXY(gameObject="Self", decelerationX=0.875, decelerationY="None", brakeOnExit=true)`

3. `PlayParticleEmitter(gameObject="Owner($Pt SpinDust)", emit=0, resetIfPlaying=true)`

4. `AudioPlayerOneShot(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClips=["GUID:78e5b1dbedf70944eacfdcd958d9b83f#8300000","GUID:1f9e86ed6916e964b86cbe8b16c513e4#8300000","GUID:98513f445f4b77a4f953c3cfe03146f9#8300000"], weights=[1,1,1], pitchMin=0.85, pitchMax=1.15, volume=1, delay=0, storePlayer="fileID:0")`



#### Death Spin L · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:24503>)

出口：FINISHED → Death Spin。isSequence=0。

1. `SetScale(gameObject="Self", vector="None", x=-1.1, y="None", z="None", everyFrame=false, lateUpdate=false)`

2. `SetVelocityByScale(gameObject="Self", speed=38, ySpeed="None", everyFrame=false)`



#### Death Pose · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:24631>)

出口：FINISHED → Spin Type；END → Final Pose 1。isSequence=0。

1. `SelectRandomString(strings=["Death Pose 1","Death Pose 2","Death Pose 3"], weights=[1,1,1], storeString="$Pose Anim")`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="$Pose Anim")`

3. `Wait(time=1, finishEvent="FINISHED", realTime=false)`

4. `GetPosition(gameObject="Self", vector="None", x="$Self X", y="None", z="None", space=0, everyFrame=false)`

5. `FloatInRange(floatVariable="$Self X", lowerValue=72.5, upperValue=75.5, boolVariable="$Centred", trueEvent=null, falseEvent=null, everyFrame=false)`

6. `IntTestToBool(int1="$Death Poses", int2=3, equalBool="None", lessThanBool="None", greaterThanBool="$Enough Poses", everyFrame=false)`

7. `BoolAllTrue(boolVariables=["$Centred","$Enough Poses"], sendEvent="END", storeResult="None", everyFrame=false)`

8. `AudioPlayRandomVoiceFromTableV2(gameObject="Owner($Audio Loop Voice)", audioClipTable="GUID:c54ac04a7d9eddf449b1d103dcc49369#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`



#### Quick Entrance 3 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:24963>)

出口：FINISHED → Appear 1。isSequence=0。

1. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Spotlight L)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="FOLLOW", delay=0, everyFrame=false)`

2. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Spotlight R)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="FOLLOW", delay=0, everyFrame=false)`

3. `Wait(time=0.5, finishEvent="FINISHED", realTime=false)`

4. `PlayParticleEmitterInState(gameObject="Owner($Pt Intro Steam)")`



#### Death Spin Random · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:25147>)

出口：R → Death Spin R；L → Death Spin L。isSequence=0。

1. `CheckXPosition(gameObject="Self", compareTo=66.23, compareToOffset=0, tolerance=0, equal=null, equalBool="None", lessThan="R", lessThanBool="None", greaterThan=null, greaterThanBool="None", everyFrame=false, space=0, activeBool="None")`

2. `CheckXPosition(gameObject="Self", compareTo=81.11, compareToOffset=0, tolerance=0, equal=null, equalBool="None", lessThan=null, lessThanBool="None", greaterThan="L", greaterThanBool="None", everyFrame=false, space=0, activeBool="None")`

3. `SendRandomEvent(events=["L","R"], weights=[1,1], delay=0)`



#### Spin Type · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:25384>)

出口：CENTRE → Death Spin Centre；RANDOM → Death Spin Random；FORCE → Force Centre；END → Final Pose 1。isSequence=0。

1. `GetPosition(gameObject="Self", vector="None", x="$Self X", y="None", z="None", space=0, everyFrame=false)`

2. `FloatInRange(floatVariable="$Self X", lowerValue=72.5, upperValue=75.5, boolVariable="$Centred", trueEvent=null, falseEvent=null, everyFrame=false)`

3. `IntTestToBool(int1="$Death Poses", int2=3, equalBool="None", lessThanBool="None", greaterThanBool="$Enough Poses", everyFrame=false)`

4. `BoolAllTrue(boolVariables=["$Centred","$Enough Poses"], sendEvent="END", storeResult="None", everyFrame=false)`

5. `BoolTestMulti(boolVariables=["$Centred","$Enough Poses"], boolStates=[0,1], trueEvent="FORCE", falseEvent=null, storeResult="None", everyFrame=false)`

6. `IntAdd(intVariable="$Death Poses", add=1, everyFrame=false)`

7. `IntCompare(integer1="$Death Poses", integer2=2, equal="RANDOM", lessThan="RANDOM", greaterThan="CENTRE", everyFrame=false)`



#### Final Pose 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:25700>)

出口：FINISHED → Final Pose 2。isSequence=0。

1. **disabled** `SelectRandomString(strings=["Death Pose 1","Death Pose 2","Death Pose 3"], weights=[1,1,1], storeString="$Pose Anim")`

2. `AudioPlaySimple(gameObject="Owner($Death Fireworks Loop)", volume=1, oneShotClip="fileID:0")`

3. `AudioPlaySimple(gameObject="Self", volume=1, oneShotClip="GUID:be777a8a4b69a144d8ee603437c7d857#8300000")`

4. `PlayAudioEvent(audioClip="GUID:f689bd61dd9534e4586bea22f21f9c21#8300000", pitchMin=1, pitchMax=1, volume=1, audioPlayerPrefab="None", spawnPoint="Self", spawnPosition={"x":0,"y":0,"z":0}, SpawnedPlayerRef="None")`

5. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:7930b85c540bf474581e7fda7871306b#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

6. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Death Pose Final")`

7. `DoCameraShake(VisibleRenderer="Owner(fileID:0)", Camera="GUID:9b0888e0916dca544846a2f34304dac9#11400000", Profile="GUID:e483858fc9bec004c905f955c1162848#11400000", cancelOnExit=false, DoFreeze=0, Delay=0)`

8. `PlayParticleEmitter(gameObject="Owner($Pt DeathStream)", emit=0, resetIfPlaying=false)`

9. `Wait(time=1, finishEvent="FINISHED", realTime=false)`

10. `ScreenFlashTrobbio()`

11. `StopParticleEmitter(gameObject="Owner($Pt IdleGlitter)")`

12. `FindChild(gameObject="Owner($Dazzle Flash)", childName="Damager", storeResult="$Dazzle Damager")`

13. `SetDamageHero(Target="Owner($Dazzle Damager)", Enabled=0)`

14. `ActivateGameObject(gameObject="Owner($Dazzle Flash)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

15. `AudioStopV2(gameObject="Owner($Drum Loop)", fadeTime=0.5, cancelOnEarlyExit=false)`



#### Final Pose 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:26189>)

出口：FINISHED → Final Fireworks。isSequence=0。

1. `PlayParticleEmitterChildren(gameObject="Owner($Steam Jets)", resetTimeIfPlaying=true, stopOnStateExit=false)`

2. `Wait(time=1, finishEvent="FINISHED", realTime=false)`

3. `AudioPlaySimple(gameObject="Owner($Smoke Loop)", volume=1, oneShotClip="fileID:0")`



#### Final Fireworks · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:26301>)

出口：FINISHED → Stop Stream。isSequence=0。

1. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Flare Glitter)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="FINAL FLARE", delay=0, everyFrame=false)`

2. `Wait(time=2.5, finishEvent="FINISHED", realTime=false)`



#### Collapse · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:26424>)

出口：FINISHED → Battle End。isSequence=0。

1. `AwardQueuedAchievements(delay=0)`

2. `CancelCameraShake(Camera="GUID:9b0888e0916dca544846a2f34304dac9#11400000", Profile="GUID:e483858fc9bec004c905f955c1162848#11400000")`

3. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Death Collapse")`

4. `SetPositionToObject(gameObject="Owner($Bind Dazzle Pickup)", targetObject="$Pickup Spot", xOffset=0, yOffset=0, zOffset=-0.001, overrideZ="None", everyFrame=false)`

5. `ActivateGameObject(gameObject="Owner($Bind Dazzle Pickup)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

6. `Wait(time=2.5, finishEvent="FINISHED", realTime=false)`

7. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:7930b85c540bf474581e7fda7871306b#8300000", pitchMin=1, pitchMax=1, volume=0.5, delay=0, storePlayer="fileID:0")`

8. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:c8b27364625a5e8498d80e98ab1f581b#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Stop Stream · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:26741>)

出口：END → Collapse。isSequence=0。

1. `StopParticleEmitter(gameObject="Owner($Pt DeathStream)")`

2. `Wait(time=1, finishEvent="END", realTime=false)`

3. `StopParticleEmittersInChildren(gameObject="Owner($Steam Jets)")`

4. `PlayParticleEmitterChildren(gameObject="Owner($Confetti Shooters)", resetTimeIfPlaying=true, stopOnStateExit=false)`

5. `DoCameraShake(VisibleRenderer="Owner(fileID:0)", Camera="GUID:9b0888e0916dca544846a2f34304dac9#11400000", Profile="GUID:bcadf15120fe09e41b0ab53ed04fe6a4#11400000", cancelOnExit=false, DoFreeze=0, Delay=0)`

6. `AudioStopV2(gameObject="Owner($Death Fireworks Loop)", fadeTime=0, cancelOnEarlyExit=false)`

7. `AudioStopV2(gameObject="Owner($Smoke Loop)", fadeTime=0, cancelOnEarlyExit=false)`

8. `PlayAudioEvent(audioClip="GUID:47f4f8b819cf96b4bb7c0843d4fec134#8300000", pitchMin=1, pitchMax=1, volume=1, audioPlayerPrefab="None", spawnPoint="Self", spawnPosition={"x":0,"y":0,"z":0}, SpawnedPlayerRef="None")`

9. `PlayAudioEvent(audioClip="GUID:f689bd61dd9534e4586bea22f21f9c21#8300000", pitchMin=1, pitchMax=1, volume=1, audioPlayerPrefab="None", spawnPoint="Self", spawnPosition={"x":0,"y":0,"z":0}, SpawnedPlayerRef="None")`



#### Battle End · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:27053>)

出口：FINISHED → Faked Death。isSequence=0。

1. `CallMethodProper(gameObject="Self", behaviour="NonBouncer", methodName="SetActive", parameters=[{"variableName":null,"objectType":"UnityEngine.Object","useVariable":0,"type":2,"floatValue":0,"intValue":0,"boolValue":1,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}], storeResult={"variableName":null,"objectType":"UnityEngine.Object","useVariable":1,"type":-1,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}, EveryFrame=false)`

2. `ActivateGameObject(gameObject="Owner($FakeDeath Range)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

3. `ActivateGameObject(gameObject="Owner($FakeDeath ExitRange)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

4. `ActivateGameObject(gameObject="Owner($CamLock Boss)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

5. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Gates)","fsmName":null,"sendToChildren":1,"fsmComponent":"fileID:0"}, sendEvent="BG OPEN", delay=0, everyFrame=false)`



#### Force Centre · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:27323>)

出口：FINISHED → Death Spin Centre。isSequence=0。

1. `SetBoolValue(boolVariable="$Force Centre", boolValue=1, everyFrame=false)`

2. `SetBoolValueAtTime(BoolVariable="None", BoolValue=0, Time=0, SetOppositeOnStateEntry=false)`



#### Force Centre? · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:27425>)

出口：FINISHED → Death Pose。isSequence=0。

1. `BoolTest(boolVariable="$Force Centre", isTrue=null, isFalse="FINISHED", everyFrame=false)`

2. `GetPosition(gameObject="Self", vector="None", x="$Self X", y="None", z="None", space=0, everyFrame=false)`

3. `FloatClamp(floatVariable="$Self X", minValue=72.6, maxValue=75.4, everyFrame=false)`

4. `SetPosition(gameObject="Self", vector="None", x="$Self X", y="None", z="None", space=0, everyFrame=false, lateUpdate=false)`



#### Item Appear · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:27607>)

出口：FINISHED → Battle End。isSequence=1。

1. `Wait(time=0.5, finishEvent=null, realTime=false)`

2. `SetPositionToObject(gameObject="Owner($Bind Dazzle Pickup)", targetObject="$Pickup Spot", xOffset=0, yOffset=0, zOffset=-0.001, overrideZ="None", everyFrame=false)`

3. `ActivateGameObject(gameObject="Owner($Bind Dazzle Pickup)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

4. `Wait(time=1, finishEvent=null, realTime=false)`



#### Faked Death · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:27766>)

出口：EXIT → Fanning；FLINCH → Flinch。isSequence=0。

1. `CheckAlertRangeByName(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, alertRangeName="FakeDeath ExitRange", storeResult=0, sendEvent=null, outOfRangeEvent="EXIT", everyFrame=true)`

2. `Trigger2dEvent(gameObject="Owner($Flinch Detector)", trigger=0, collideTag="Nail Attack", sendEvent="FLINCH", storeCollider="None")`



#### Fanning · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:27923>)

出口：ENTER → Startle Pause。isSequence=0。

1. `ActivateGameObject(gameObject="Owner($Fake Death Sprite)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

2. `SetMeshRenderer(gameObject="Self", active=0)`

3. `CheckAlertRangeByName(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, alertRangeName="FakeDeath Range", storeResult=0, sendEvent="ENTER", outOfRangeEvent=null, everyFrame=true)`

4. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=0, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

5. `AudioPlaySimple(gameObject="Owner($Audio Loop Fake Death)", volume=1, oneShotClip="fileID:0")`

6. `ActivateGameObject(gameObject="Owner($Flinch Detector)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`



#### Startle Pause · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:28177>)

出口：FINISHED → Range Check。isSequence=0。

1. `Wait(time=0.1, finishEvent="FINISHED", realTime=false)`



#### Range Check · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:28250>)

出口：FINISHED → Startle；CANCEL → Faked Death。isSequence=0。

1. `CheckAlertRangeByName(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, alertRangeName="FakeDeath Range", storeResult=0, sendEvent=null, outOfRangeEvent="CANCEL", everyFrame=false)`



#### Startle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:28379>)

出口：FINISHED → Re-Collapse。isSequence=0。

1. `AudioStopV2(gameObject="Owner($Audio Loop Fake Death)", fadeTime=0, cancelOnEarlyExit=false)`

2. `Tk2dPlayAnimation(gameObject="Owner($Fake Death Sprite)", animLibName=null, clipName="Death Startle")`

3. `Wait(time=0.2, finishEvent="FINISHED", realTime=false)`

4. `PlayAudioEventRandom(audioClips={"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":12,"objectTypeName":"UnityEngine.AudioClip","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":["GUID:8426fe2430b7d5a479c4767dd891c173#8300000","GUID:c8a67deebb995864c9ee1886c1f44741#8300000","GUID:9041de9e6f0fb884a81835c87727a124#8300000","GUID:9ce42bdcafe4b3046a36c6821c2a3c01#8300000"]}, pitchMin=1, pitchMax=1, volume=0.6, audioPlayerPrefab="None", spawnPoint="Self", spawnPosition={"x":0,"y":0,"z":0}, SpawnedPlayerRef="None")`



#### Re-Collapse · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:28568>)

出口：FINISHED → Faked Death。isSequence=0。

1. `ActivateGameObject(gameObject="Owner($Fake Death Sprite)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

2. `SetMeshRenderer(gameObject="Self", active=1)`

3. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Death Collapse")`

4. `Wait(time=1, finishEvent="FINISHED", realTime=false)`

5. `Tk2dPlayFrame(gameObject="Self", frame=0)`

6. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:7930b85c540bf474581e7fda7871306b#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### State · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:28788>)

出口：MEET → Wait；REFIGHT → Wait Refight。isSequence=0。

1. `PlayerDataBoolTest(boolName="encounteredTrobbio", isTrue="REFIGHT", isFalse="MEET")`



#### Wait · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:28871>)

出口：ENTER → Take Control。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=0)`

2. `Trigger2dEvent(gameObject="Owner($Start Range Meet)", trigger=0, collideTag=null, sendEvent="ENTER", storeCollider="None")`



#### Take Control · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:28978>)

出口：LAND → Intro Jet。isSequence=0。

1. `TransitionToAudioSnapshot(snapshot="GUID:1e5b83863824c3e46b1a27345f960db5#24500034", transitionTime=3)`

2. `SetPlayerDataBool(boolName="disablePause", value=1)`

3. `RunFSM(fsmTemplateControl={"targetType":0,"target":"GUID:6acb65dd9070fec409d4a74210794792#11400000","inputVariables":[{"variable":"$Clamp X","fsmVar":{"variableName":null,"objectType":"UnityEngine.Object","useVariable":0,"type":0,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}},"isEdited":0}],"outputVariables":[],"outputEvents":[]}, finishEvent="LAND", everyFrame=false)`

4. `ActivateGameObject(gameObject="Owner($CamLock Intro)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

5. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Gates)","fsmName":null,"sendToChildren":1,"fsmComponent":"fileID:0"}, sendEvent="BG CLOSE", delay=0, everyFrame=false)`



#### Convo 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:29192>)

出口：CONVO_END → End Dialogue。isSequence=0。

1. **disabled** `PlayAudioEvent(audioClip="GUID:e555ae2e65da73844ba15e029835a7fc#8300000", pitchMin=1, pitchMax=1, volume=1, audioPlayerPrefab="GUID:e8466d04a5c03bc4b8d6a0838af84de7#82724804207875695", spawnPoint="Self", spawnPosition={"x":0,"y":0,"z":0}, SpawnedPlayerRef="None")`

2. `ActivateInteractible(Target="Self", Activate=1, AllowQueueing=0, UseChildren=0)`

3. `SendMessage(gameObject="Owner($Hero)", delivery=0, options=1, functionCall={"FunctionName":"StopAnimationControl","parameterType":"None","BoolParameter":0,"FloatParameter":0,"IntParameter":0,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`

4. `Tk2dPlayAnimation(gameObject="Owner($Hero)", animLibName=null, clipName="LookUp")`

5. `RunDialogue(Sheet="City", Key="TROBBIO_BOSS_MEET", OverrideContinue=0, PlayerVoiceTableOverride="fileID:0", PreventHeroAnimation=1, HideDecorators=0, TextAlignment=0, OffsetY=0, Target="Self")`



#### End Dialogue · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:29578>)

出口：FINISHED → Start Pause。isSequence=0。

1. `SendMessage(gameObject="Owner($Hero)", delivery=0, options=1, functionCall={"FunctionName":"StartAnimationControl","parameterType":"None","BoolParameter":0,"FloatParameter":0,"IntParameter":0,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`

2. `ActivateInteractible(Target="Self", Activate=0, AllowQueueing=0, UseChildren=0)`

3. `EndDialogue(ReturnControl=1, ReturnHUD=1, Target="Self", UseChildren=0)`

4. `SetPlayerDataBool(boolName="disablePause", value=0)`

5. `Wait(time=1, finishEvent="FINISHED", realTime=false)`



#### Intro Jet · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:29868>)

出口：FINISHED → Convo 1。isSequence=0。

1. `Wait(time=2, finishEvent="FINISHED", realTime=false)`

2. **disabled** `SendMessage(gameObject="Owner($Hero)", delivery=0, options=1, functionCall={"FunctionName":"StopAnimationControl","parameterType":"None","BoolParameter":0,"FloatParameter":0,"IntParameter":0,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`

3. **disabled** `Tk2dPlayAnimation(gameObject="Owner($Hero)", animLibName=null, clipName="Roar Lock")`

4. `DoCameraShake(VisibleRenderer="Owner(fileID:0)", Camera="GUID:9b0888e0916dca544846a2f34304dac9#11400000", Profile="GUID:bcadf15120fe09e41b0ab53ed04fe6a4#11400000", cancelOnExit=false, DoFreeze=1, Delay=0)`

5. **disabled** `CallMethodProper(gameObject="Owner($Hero)", behaviour="HeroController", methodName="StopAnimationControl", parameters=[], storeResult={"variableName":null,"objectType":"UnityEngine.Object","useVariable":1,"type":0,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}, EveryFrame=false)`



#### Flinch · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:30198>)

出口：FINISHED → Faked Death。isSequence=0。

1. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Death Collapse")`

2. `Tk2dPlayFrame(gameObject="Self", frame=0)`

3. `AudioPlayRandomVoiceFromTable(gameObject="Owner($Audio Loop Voice)", audioClipTable="GUID:3d006d929469a87498fe1074efe4f9a6#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`



#### Hornet Dead · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:30324>)

出口：无本地迁移（持续/外部驱动）。isSequence=0。

1. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Pose Victory")`

3. `AudioPlayRandomVoiceFromTable(gameObject="Self", audioClipTable="GUID:086ae2f2a6c4ac443944b7e51a715889#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`

4. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:0e0686f9ecd22fb45a43c145e0ea3893#8300000", pitchMin=0.85, pitchMax=1.15, volume=1, delay=0, storePlayer="fileID:0")`



#### Post Dazzle Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:30518>)

出口：FINISHED → Pose?。isSequence=0。

1. `Wait(time=0.2, finishEvent="FINISHED", realTime=false)`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Idle")`

3. `SetIntValue(intVariable="$Poses", intValue=1, everyFrame=false)`



#### Tornado Multihit · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:30633>)

出口：FINISHED → Tornado Recoil。isSequence=0。

1. `SetPosition(gameObject="Self", vector="None", x="None", y="None", z=0.003, space=0, everyFrame=false, lateUpdate=false)`

2. `SetVelocity2d(gameObject="Self", vector={"x":0,"y":0}, x="None", y="None", everyFrame=false)`

3. `Wait(time=0.35, finishEvent="FINISHED", realTime=false)`



#### Tornado Recoil · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:30781>)

出口：FINISHED → Tornado Shoot。isSequence=0。

1. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

2. `SetVelocityByScale(gameObject="Self", speed=-30, ySpeed="None", everyFrame=false)`

3. `DecelerateXY(gameObject="Self", decelerationX=0.9, decelerationY="None", brakeOnExit=false)`

4. `Wait(time=0.1, finishEvent="FINISHED", realTime=false)`

5. `SetPosition(gameObject="Self", vector="None", x="None", y="None", z=0.006, space=0, everyFrame=false, lateUpdate=false)`



#### Tornado Evade · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:30984>)

出口：FINISHED → Tornado Evade Land；EXIT → Exit or Cancel。isSequence=0。

1. `SetBoolValue(boolVariable="$Evade Cooling Down", boolValue=1, everyFrame=false)`

2. `AudioPlayRandomVoiceFromTable(gameObject="Self", audioClipTable="GUID:04dc803f796a4904781857565052868a#11400000", pitchOffset=0, stopPreviousSound=false, forcePlay=false)`

3. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

4. `RayCast2dV2(fromGameObject="Owner($Ray Pt Centre)", fromPosition="None", direction={"x":-1,"y":0}, space=1, distance=6, minDepth="None", maxDepth="None", hitEvent="EXIT", noHitEvent=null, storeDidHit="None", storeHitObject="None", storeHitPoint="None", storeHitNormal="None", storeHitDistance="None", storeDistance="None", repeatInterval=0, layerMask=[8], invertMask=0, ignoreTriggers=0, debugColor={"r":1,"g":0.92156863,"b":0.015686275,"a":1}, debug=0)`

5. `SetInvincible(target="Self", Invincible=1, InvincibleFromDirection=13, resetOnStateExit=true)`

6. `SetVelocityByScale(gameObject="Self", speed=-75, ySpeed="None", everyFrame=false)`

7. `DecelerateXY(gameObject="Self", decelerationX=0.855, decelerationY="None", brakeOnExit=false)`

8. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Tornado Evade", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`

9. **disabled** `AudioPlaySimple(gameObject="Owner($Tornado Loop)", volume=1, oneShotClip="fileID:0")`

10. **disabled** `AudioPlayInState(gameObject="Owner($Tornado Loop)", volume=1)`

11. **disabled** `SetAudioPitch(gameObject="Owner($Tornado Loop)", pitch=1.75, everyFrame=false)`

12. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:adc77539bcbdf2447a275ca37b12778b#8300000", pitchMin=1.5, pitchMax=1.5, volume=1, delay=0, storePlayer="fileID:0")`

13. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:05014101a5989d94da43736874583fdd#8300000", pitchMin=1.25, pitchMax=1.25, volume=1, delay=0, storePlayer="fileID:0")`

14. `PlayParticleEmitterChildren(gameObject="Owner($Pt Tornado Dust)", resetTimeIfPlaying=true, stopOnStateExit=true)`

15. `ActivateGameObject(gameObject="Owner($Terrain Saver)", activate=1, recursive=0, resetOnExit=true, everyFrame=false)`



#### Evade? · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:31587>)

出口：FINISHED → Choice；EVADE → Tornado Evade；COOLDOWN → Reset Evade CD。isSequence=0。

1. `BoolTest(boolVariable="$Evade Cooling Down", isTrue="COOLDOWN", isFalse=null, everyFrame=false)`

2. `CheckAlertRangeByName(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, alertRangeName="Evade Range", storeResult=0, sendEvent="EVADE", outOfRangeEvent=null, everyFrame=false)`



#### Reset Evade CD · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:31739>)

出口：FINISHED → Choice。isSequence=0。

1. `SetBoolValue(boolVariable="$Evade Cooling Down", boolValue=0, everyFrame=false)`



#### Tornado Evade Land · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:31817>)

出口：FINISHED → Choice。isSequence=0。

1. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:7930b85c540bf474581e7fda7871306b#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

2. `DecelerateXY(gameObject="Self", decelerationX=0.855, decelerationY="None", brakeOnExit=true)`

3. `Tk2dWatchAnimationEvents(gameObject="Self", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

4. `PlayParticleEmitterChildren(gameObject="Owner($Pt Tornado Dust)", resetTimeIfPlaying=true, stopOnStateExit=true)`

5. `ActivateGameObject(gameObject="Owner($Terrain Saver)", activate=1, recursive=0, resetOnExit=true, everyFrame=false)`



#### BC Pause · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:32018>)

出口：FINISHED → BC Attack。isSequence=0。

1. `Wait(time=1, finishEvent="FINISHED", realTime=false)`

2. `WaitBool(boolTest="$Phase 2", time=0.5, finishEvent="FINISHED", realTime=false)`



#### Will Burst Column · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:32110>)

出口：FINISHED → Exit 1。isSequence=0。

1. `SetBoolValue(boolVariable="$Will Burst Column", boolValue=1, everyFrame=false)`



#### BC Attack · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:32188>)

出口：FINAL BURST → Final Burst Set。isSequence=0。

1. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Trapdoor Bursts)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="ATTACK", delay=0, everyFrame=false)`



#### Final Burst Set · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:32299>)

出口：FINISHED → Final Burst。isSequence=0。

1. `GetPosition2d(gameObject="Owner($Final Burst)", vector_2d="None", x="$Self X", y="None", space=0, everyFrame=false)`

2. `SetPosition2d(gameObject="Self", vector="None", x="$Self X", y="None", space=0, everyFrame=false, lateUpdate=false)`

3. `Wait(time=0.95, finishEvent="FINISHED", realTime=false)`



#### Final Burst · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:32441>)

出口：FINISHED → Enter 1。isSequence=0。

1. `SetPosition(gameObject="Self", vector="None", x="None", y="$Floor Y", z="None", space=0, everyFrame=false, lateUpdate=false)`

2. `SetBoolValue(boolVariable="$Phase 2", boolValue=1, everyFrame=false)`

3. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:0e0686f9ecd22fb45a43c145e0ea3893#8300000", pitchMin=0.85, pitchMax=1.15, volume=1, delay=0, storePlayer="fileID:0")`



#### Phase Roar Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:32620>)

出口：FINISHED → Phase Roar。isSequence=0。

1. `SetRecoilBlocked(Target="Self", IsUpBlocked=1, IsDownBlocked=1, IsLeftBlocked=1, IsRightBlocked=1)`

2. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:1f9e86ed6916e964b86cbe8b16c513e4#8300000", pitchMin=0.85, pitchMax=1.15, volume=1, delay=0, storePlayer="fileID:0")`

3. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="STUN CONTROL STOP", delay=0, everyFrame=false)`

4. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

5. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Phase Roar", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`



#### Phase Roar · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:32887>)

出口：FINISHED → Phase Roar End。isSequence=0。

1. `StartRoarEmitter(spawnPoint="Self", delay=0, stunHero=0, roarBurst=0, isSmall=0, noVisualEffect=0, forceThroughBind=0, stopOnExit=true)`

2. `Wait(time=1.5, finishEvent="FINISHED", realTime=false)`

3. `AudioPlaySimple(gameObject="Self", volume=1, oneShotClip="GUID:e261fc334ef90624a8d2749685ee0d7e#8300000")`

4. `PlayAudioEvent(audioClip="GUID:7b31832c38310bd469ae8734210fb9f7#8300000", pitchMin=1, pitchMax=1, volume=1, audioPlayerPrefab="GUID:e8466d04a5c03bc4b8d6a0838af84de7#82724804207875695", spawnPoint="Self", spawnPosition={"x":0,"y":0,"z":0}, SpawnedPlayerRef="None")`

5. `SetBoolValue(boolVariable="$Doing First Burst Column", boolValue=1, everyFrame=false)`

6. `SetBoolValue(boolVariable="$Will Burst Column", boolValue=1, everyFrame=false)`

7. `SetBoolValue(boolVariable="$Phase 2", boolValue=1, everyFrame=false)`



#### Phase Roar End · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:33153>)

出口：FINISHED → Exit 1。isSequence=0。

1. `SetBoolValue(boolVariable="$Doing First Burst Column", boolValue=1, everyFrame=false)`

2. `SetBoolValue(boolVariable="$Will Burst Column", boolValue=1, everyFrame=false)`

3. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="STUN CONTROL START", delay=0, everyFrame=false)`

4. `SetRecoilBlocked(Target="Self", IsUpBlocked=0, IsDownBlocked=0, IsLeftBlocked=0, IsRightBlocked=0)`



#### Flash Start Air · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:33337>)

出口：FINISHED → Flash Rise Air；CANCEL → Jump Attack 2。isSequence=0。

1. `GetFsmBool(gameObject="Owner($Flare Glitter)", fsmName="Control", variableName="Active", storeValue="$Flare Glitter Active", everyFrame=false)`

2. `BoolTest(boolVariable="$Flare Glitter Active", isTrue="CANCEL", isFalse=null, everyFrame=false)`

3. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

4. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Flash Attack Air", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`

5. `SetGravity2dScale(gameObject="Self", gravityScale=0)`

6. `DecelerateV2(gameObject="Self", deceleration=0.875, brakeOnExit=false)`



#### Flash Rise Air · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:33549>)

出口：FINISHED → Flash Burst。isSequence=0。

1. `SetGravity2dScale(gameObject="Self", gravityScale=0)`

2. `SetVelocity2d(gameObject="Self", vector="None", x=0, y=15, everyFrame=false)`

3. `Tk2dWatchAnimationEvents(gameObject="Self", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`

4. `DecelerateV2(gameObject="Self", deceleration=0.825, brakeOnExit=false)`

5. `AudioPlayRandomVoiceFromTable(gameObject="Self", audioClipTable="GUID:00245b57a4ba4ec4681a896947d10a28#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`

6. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:9edc4820c94536845964fb16515538f7#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Exit or Cancel · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:33776>)

出口：EXIT → Exit 1；CANCEL → Choice。isSequence=0。

1. `SendRandomEventV4(events=["EXIT","CANCEL"], weights=[1,1], eventMax=[1,1], missedMax=[1,1], activeBool="None")`



#### Sing · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:33909>)

出口：SING DURATION END → Sing End。isSequence=0。

1. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Sing")`

2. `EnemySingControl(enemyGameObject="Self", audioPlayer="$Audio Loop Voice", singAudioTable="GUID:daec7ecfd575804449ca88d298c77b08#11400000", noThreadEffects=1, noPuppetString=0, randomSingStartTime=0, dontStopAudioOnExit=0, altThreadSpawnPoint="fileID:0")`

3. `CheckHeroPerformanceRegionV2(Target="Self", Radius=0, MinReactDelay=0.5, MaxReactDelay=0.6, None="SING DURATION END", ActiveInner=null, ActiveOuter=null, IgnoreNeedolinRange=0, UseActiveBool=0, ActiveBool="None", StoreState="None", EveryFrame=true)`

4. `SetVelocity2d(gameObject="Self", vector="None", x=0, y="None", everyFrame=false)`

5. `AudioPlayerOneShot(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClips=["GUID:78e5b1dbedf70944eacfdcd958d9b83f#8300000","GUID:1f9e86ed6916e964b86cbe8b16c513e4#8300000","GUID:98513f445f4b77a4f953c3cfe03146f9#8300000"], weights=[1,1,1], pitchMin=0.85, pitchMax=1.15, volume=1, delay=0, storePlayer="fileID:0")`



#### Sing End · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:34239>)

出口：FINISHED → Evade?。isSequence=0。



#### Tornado Antic 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:34300>)

出口：FINISHED → Tornado Start。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Tornado Antic", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `AudioPlaySimple(gameObject="Owner($Tornado Loop)", volume=1, oneShotClip="fileID:0")`

3. `AudioPlayRandomVoiceFromTable(gameObject="Self", audioClipTable="GUID:00245b57a4ba4ec4681a896947d10a28#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`

4. `SetAudioPitch(gameObject="Owner($Tornado Loop)", pitch=1, everyFrame=false)`

5. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:adc77539bcbdf2447a275ca37b12778b#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Death Catch · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:34509>)

出口：FINISHED → Death Land。isSequence=0。

1. `GetPosition2d(gameObject="Self", vector_2d="None", x="None", y="$Y Pos", space=0, everyFrame=false)`

2. `FloatClamp(floatVariable="$Y Pos", minValue=16.7, maxValue=1000, everyFrame=false)`

3. `SetPosition2d(gameObject="Self", vector="None", x="None", y="$Y Pos", space=0, everyFrame=false, lateUpdate=false)`



### Trobbio / Tornado Emission [fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:35558>)

变量初值：`{"gameObjectVariables":{"Pt Tornado Dust":{"fileID":1313026266067498}}}`

全局迁移：`[]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:35575>)

出口：FINISHED → Floor。isSequence=0。



#### Floor · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:35636>)

出口：UP → Up。isSequence=0。

1. `CheckYPosition(gameObject="Self", compareTo=19.4, compareToOffset=0, tolerance=0, equal=null, lessThan=null, greaterThan="UP", everyFrame=true, space=0, activeBool="None")`

2. `SetPosition(gameObject="Owner($Pt Tornado Dust)", vector="None", x="None", y=0, z="None", space=1, everyFrame=false, lateUpdate=false)`



#### Up · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:35786>)

出口：DOWN → Floor。isSequence=0。

1. `CheckYPosition(gameObject="Self", compareTo=19.4, compareToOffset=0, tolerance=0, equal=null, lessThan="DOWN", greaterThan=null, everyFrame=true, space=0, activeBool="None")`

2. `SetPosition(gameObject="Owner($Pt Tornado Dust)", vector="None", x="None", y=-100, z="None", space=1, everyFrame=false, lateUpdate=false)`



### Trobbio / Stun Control [fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:36020>)

变量初值：`{"floatVariables":{"Combo Time":1},"intVariables":{"(blank)":0,"Stun Combo":12,"Stun Hit Max":14},"gameObjectVariables":{"(blank)":{"fileID":0}}}`

全局迁移：`[]`

#### State 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:36037>)

出口：无本地迁移（持续/外部驱动）。isSequence=0。



### Tornado Damager / FSM [fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:46133>)

变量初值：`{"boolVariables":{"(blank)":0,"Hazard Hit":0,"z1 Lag Hit":0,"z2 Steam Hazard":0},"stringVariables":{"(blank)":null},"gameObjectVariables":{"(blank)":{"fileID":0}}}`

全局迁移：`[]`

#### State 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:46150>)

出口：无本地迁移（持续/外部驱动）。isSequence=0。



### Tornado Event Sender / Tornado Event Sender [fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:77962>)

变量初值：`{"gameObjectVariables":{"(blank)":{"fileID":0}}}`

全局迁移：`[]`

#### State 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:77979>)

出口：无本地迁移（持续/外部驱动）。isSequence=0。



### Trobbio Bomb / Control [projectile_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio Bomb.prefab:456>)

变量初值：`{"floatVariables":{"Spin Amount":0,"X Velocity":0,"Y Velocity":0,"Y Velocity Crt":0,"X Velocity Crt":0,"Bounce Speed":0,"Timer":0,"Rotation":0,"Self Y":0,"Explode Y Min":15.5,"Explode Y Max":22.5,"Self X":0,"Explode X Max":86,"Explode X Min":62,"(blank)":0,"Fling Speed":0,"Pitch":0},"boolVariables":{"In Range X":0,"Time Up":0,"In Range Y":0},"gameObjectVariables":{"Sprite":{"fileID":1730242686860875},"Pt Idle":{"fileID":1724804207875695},"Pt Antic":{"fileID":1618682377417806},"Blast":{"fileID":1709867586078768},"Pt Land":{"fileID":1161607090078389},"Self":{"fileID":1709254077376921}}}`

全局迁移：`[]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio Bomb.prefab:473>)

出口：FINISHED → Fling。isSequence=0。

1. `RandomFloat(min=40, max=28, storeResult="$Bounce Speed")`

2. `RandomFloat(min=1, max=1.7, storeResult="$Timer")`

3. `SetIsKinematic2d(gameObject="Self", isKinematic=0)`

4. `Tk2dPlayAnimation(gameObject="Owner($Sprite)", animLibName=null, clipName="Bomb Idle")`

5. `ActivateGameObject(gameObject="Owner($Sprite)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

6. `PlayParticleEmitter(gameObject="Owner($Pt Idle)", emit=0, resetIfPlaying=false)`

7. `SetCollider(gameObject="Self", active=1, resetOnExit=false)`

8. `FloatOperator(float1="$Bounce Speed", float2=6, operation=1, storeResult="$Fling Speed", everyFrame=false)`

9. `CheckYPosition(gameObject="Self", compareTo=20, compareToOffset=0, tolerance=0, equal=null, lessThan="FINISHED", greaterThan=null, everyFrame=false, space=0, activeBool="None")`

10. `FloatOperator(float1="$Bounce Speed", float2=10, operation=1, storeResult="$Fling Speed", everyFrame=false)`

11. `FloatClamp(floatVariable="$Fling Speed", minValue=0, maxValue=22, everyFrame=false)`



#### Air · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio Bomb.prefab:809>)

出口：WALL L → Wall L；WALL R → Wall R；FLOOR → Floor；TIME UP → Antic；TINK LEFT → Hit L；TINK RIGHT → Hit R；TINK UP → Tink U；TINK DOWN → Tink D；HERO DAMAGED → Hit Hero；PROJECTILE BREAK → Explode；STOPPED → Stopped Fix。isSequence=0。

1. `RandomFloat(min=200, max=600, storeResult="$Spin Amount")`

2. `RandomlyFlipFloat(storeResult="$Spin Amount")`

3. `Rotate(gameObject="Owner($Sprite)", vector="None", xAngle="None", yAngle="None", zAngle="$Spin Amount", space=1, perSecond=true, everyFrame=true, lateUpdate=false, fixedUpdate=false)`

4. `CheckCollisionSideEnter(topHit="None", rightHit="None", bottomHit="None", leftHit="None", topHitEvent=null, rightHitEvent="WALL R", bottomHitEvent="FLOOR", leftHitEvent="WALL L", otherLayer=false, otherLayerNumber=0, ignoreTriggers=0)`

5. `CheckCollisionSide(collidingObject="Self", topHit="None", rightHit="None", bottomHit="None", leftHit="None", topHitEvent=null, rightHitEvent="WALL R", bottomHitEvent="FLOOR", leftHitEvent="WALL L", otherLayer=false, otherLayerNumber=0, ignoreTriggers=0)`

6. **disabled** `SetFloatValue(floatVariable="$X Velocity", floatValue="$X Velocity Crt", everyFrame=false)`

7. **disabled** `SetFloatValue(floatVariable="$Y Velocity", floatValue="$Y Velocity Crt", everyFrame=false)`

8. `GetVelocity2d(gameObject="Self", vector="None", x="$X Velocity Crt", y="None", space=0, everyFrame=true)`

9. `FloatAdd(floatVariable="$Timer", add=-1, everyFrame=true, perSecond=true)`

10. `FloatTestToBool(float1="$Timer", float2=0, tolerance=0, equalBool="None", lessThanBool="$Time Up", greaterThanBool="None", everyFrame=true)`

11. `GetPosition2D(gameObject="Self", vector="None", x="$Self X", y="$Self Y", space=0, everyFrame=true)`

12. `FloatInRange(floatVariable="$Self X", lowerValue="$Explode X Min", upperValue="$Explode X Max", boolVariable="$In Range X", trueEvent=null, falseEvent=null, everyFrame=true)`

13. `FloatInRange(floatVariable="$Self Y", lowerValue="$Explode Y Min", upperValue="$Explode Y Max", boolVariable="$In Range Y", trueEvent=null, falseEvent=null, everyFrame=true)`

14. `BoolAllTrue(boolVariables=["$In Range X","$In Range Y","$Time Up"], sendEvent="TIME UP", storeResult="None", everyFrame=true)`

15. `ReceivedDamage(Target="Self", collideTag="None", sendEvent=null, sendEventHeavy="PROJECTILE BREAK", sendEventSpikes=null, sendEventLava=null, sendEventLightning=null, storeGameObject="None", ignoreAcid=0, ignoreLava=0, ignoreWater=0, ignoreHunterWeapon=0, ignoreTraps=0, ignoreNail=0, ignoreSpikes=0, storeDamageDealt="None", storeDirection="None", storeMagnitudeMultiplier="None", firstHitOnly=0)`

16. `FloatCompare(float1="$X Velocity Crt", float2=0, tolerance=0.01, equal="STOPPED", lessThan=null, greaterThan=null, everyFrame=true)`



#### Wall L · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio Bomb.prefab:1551>)

出口：FINISHED → Air。isSequence=0。

1. `FloatMultiply(floatVariable="$X Velocity", multiplyBy=-1, everyFrame=false)`

2. `SetVelocity2d(gameObject="Self", vector="None", x="$X Velocity", y="None", everyFrame=false)`

3. `Translate(gameObject="Self", vector="None", x=0.25, y="None", z="None", space=0, perSecond=false, everyFrame=false, lateUpdate=false, fixedUpdate=false)`

4. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:36af8a9ffa45fa34b88c373743684e7d#8300000", pitchMin=0.8, pitchMax=1.2, volume=1, delay=0, storePlayer="fileID:0")`



#### Wall R · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio Bomb.prefab:1765>)

出口：FINISHED → Air。isSequence=0。

1. `FloatMultiply(floatVariable="$X Velocity", multiplyBy=-1, everyFrame=false)`

2. `SetVelocity2d(gameObject="Self", vector="None", x="$X Velocity", y="None", everyFrame=false)`

3. `Translate(gameObject="Self", vector="None", x=-0.25, y="None", z="None", space=0, perSecond=false, everyFrame=false, lateUpdate=false, fixedUpdate=false)`

4. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:36af8a9ffa45fa34b88c373743684e7d#8300000", pitchMin=0.8, pitchMax=1.2, volume=1, delay=0, storePlayer="fileID:0")`



#### Floor · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio Bomb.prefab:1979>)

出口：FINISHED → Air。isSequence=0。

1. `FloatMultiply(floatVariable="$Y Velocity", multiplyBy=-1, everyFrame=false)`

2. `SetVelocity2d(gameObject="Self", vector="None", x="None", y="$Bounce Speed", everyFrame=false)`

3. **disabled** `Translate(gameObject="Self", vector="None", x="None", y=0.25, z="None", space=0, perSecond=false, everyFrame=false, lateUpdate=false, fixedUpdate=false)`

4. **disabled** `PlayParticleEmitter(gameObject="Owner($Pt Land)", emit=0, resetIfPlaying=false)`

5. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:36af8a9ffa45fa34b88c373743684e7d#8300000", pitchMin=0.8, pitchMax=1.2, volume=1, delay=0, storePlayer="fileID:0")`



#### Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio Bomb.prefab:2212>)

出口：FINISHED → Explode；HERO DAMAGED → Explode；PROJECTILE BREAK → Explode。isSequence=0。

1. `SetRotation(gameObject="Owner($Sprite)", quaternion="None", vector="None", xAngle="None", yAngle="None", zAngle=0, space=0, everyFrame=false, lateUpdate=false)`

2. `AudioStop(gameObject="Self", fadeTime=0)`

3. `SetIsKinematic2d(gameObject="Self", isKinematic=1)`

4. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:3ee9fbc28579cd8489fc3c360240c209#8300000", pitchMin=0.9, pitchMax=1.1, volume=1, delay=0, storePlayer="fileID:0")`

5. `StopParticleEmitter(gameObject="Owner($Pt Idle)")`

6. `Tk2dPlayAnimation(gameObject="Owner($Sprite)", animLibName=null, clipName="Bomb Antic")`

7. `DecelerateV2(gameObject="Self", deceleration=0.84, brakeOnExit=false)`

8. **disabled** `RandomFloatEither(value1=90, value2=180, storeResult="$Rotation")`

9. **disabled** `RandomlyFlipFloat(storeResult="$Rotation")`

10. `SetRotation(gameObject="Self", quaternion="None", vector="None", xAngle="None", yAngle="None", zAngle="$Rotation", space=0, everyFrame=false, lateUpdate=false)`

11. `PlayParticleEmitterChildren(gameObject="Owner($Pt Antic)", resetTimeIfPlaying=false, stopOnStateExit=true)`

12. `Wait(time=0.75, finishEvent="FINISHED", realTime=false)`

13. `ReceivedDamage(Target="Self", collideTag="None", sendEvent="FINISHED", sendEventHeavy=null, sendEventSpikes=null, sendEventLava=null, sendEventLightning=null, storeGameObject="None", ignoreAcid=0, ignoreLava=0, ignoreWater=0, ignoreHunterWeapon=0, ignoreTraps=0, ignoreNail=0, ignoreSpikes=0, storeDamageDealt="None", storeDirection="None", storeMagnitudeMultiplier="None", firstHitOnly=0)`

14. `ClampPosition(gameObject="Self", minX="None", maxX="None", minY="$Explode Y Min", maxY="None", minZ="None", maxZ="None", space=0, everyFrame=true, lateUpdate=false)`



#### Explode · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio Bomb.prefab:2764>)

出口：FINISHED → Recycle。isSequence=0。

1. `SetVelocity2d(gameObject="Self", vector={"x":0,"y":0}, x="None", y="None", everyFrame=false)`

2. `SetIsKinematic2d(gameObject="Self", isKinematic=1)`

3. `Tk2dPlayAnimation(gameObject="Owner($Sprite)", animLibName=null, clipName="Bomb Blow")`

4. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:a42a6a36fd75d3f47aefe9bc33d119f5#8300000", pitchMin=0.85, pitchMax=1.15, volume=1, delay=0, storePlayer="fileID:0")`

5. `Wait(time=2, finishEvent="FINISHED", realTime=false)`

6. `ActivateGameObject(gameObject="Owner($Blast)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

7. `DoCameraShake(VisibleRenderer="Self", Camera="GUID:9b0888e0916dca544846a2f34304dac9#11400000", Profile="GUID:3e660b394608b7a4e822f55cc03492d7#11400000", cancelOnExit=false, DoFreeze=0, Delay=0)`

8. `SetCollider(gameObject="Self", active=0, resetOnExit=false)`



#### Recycle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio Bomb.prefab:3060>)

出口：无本地迁移（持续/外部驱动）。isSequence=0。

1. `ActivateGameObject(gameObject="Owner($Blast)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

2. `RecycleSelf()`



#### Hit L · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio Bomb.prefab:3141>)

出口：FINISHED → Air。isSequence=0。

1. `SetVelocity2d(gameObject="Self", vector="None", x=-12, y="None", everyFrame=false)`

2. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:36af8a9ffa45fa34b88c373743684e7d#8300000", pitchMin=0.8, pitchMax=1.2, volume=1, delay=0, storePlayer="fileID:0")`



#### Hit R · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio Bomb.prefab:3294>)

出口：FINISHED → Air。isSequence=0。

1. `SetVelocity2d(gameObject="Self", vector="None", x=12, y="None", everyFrame=false)`

2. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:36af8a9ffa45fa34b88c373743684e7d#8300000", pitchMin=0.8, pitchMax=1.2, volume=1, delay=0, storePlayer="fileID:0")`



#### Tink U · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio Bomb.prefab:3447>)

出口：FINISHED → Floor。isSequence=0。



#### Tink D · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio Bomb.prefab:3508>)

出口：FINISHED → Air。isSequence=0。

1. `SetVelocity2d(gameObject="Self", vector="None", x="None", y=-20, everyFrame=false)`

2. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:36af8a9ffa45fa34b88c373743684e7d#8300000", pitchMin=0.8, pitchMax=1.2, volume=1, delay=0, storePlayer="fileID:0")`



#### Fling · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio Bomb.prefab:3661>)

出口：FINISHED → Air。isSequence=0。

1. `SetVelocity2d(gameObject="Self", vector="None", x="None", y="$Fling Speed", everyFrame=false)`

2. `RandomFloat(min=0.85, max=1.15, storeResult="$Pitch")`

3. `SetAudioPitch(gameObject="Self", pitch="$Pitch", everyFrame=false)`

4. `AudioPlaySimple(gameObject="Self", volume=1, oneShotClip="fileID:0")`



#### Hit Hero · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio Bomb.prefab:3823>)

出口：FINISHED → Explode。isSequence=0。

1. `SetIsKinematic2d(gameObject="Self", isKinematic=1)`

2. `StopParticleEmitter(gameObject="Owner($Pt Idle)")`

3. **disabled** `RandomFloatEither(value1=90, value2=180, storeResult="$Rotation")`

4. **disabled** `RandomlyFlipFloat(storeResult="$Rotation")`

5. `SetRotation(gameObject="Self", quaternion="None", vector="None", xAngle="None", yAngle="None", zAngle="$Rotation", space=0, everyFrame=false, lateUpdate=false)`

6. `SetVelocity2d(gameObject="Self", vector={"x":0,"y":0}, x="None", y="None", everyFrame=false)`



#### Stopped Fix · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio Bomb.prefab:4027>)

出口：WALL L → Hit L；WALL R → Hit R。isSequence=0。

1. `SendRandomEvent(events=["WALL L","WALL R"], weights=[1,1], delay=0)`



### Trapdoor Bursts / Control [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1563415>)

变量初值：`{"floatVariables":{"Delay 1":0,"Delay Max":0.85,"Delay Min":0,"Shift X":0,"Delay 2":0,"Delay 3":0,"Delay 4":0},"gameObjectVariables":{"Bursts":{"fileID":0},"Burst A":{"fileID":0},"Burst B":{"fileID":0},"Burst C":{"fileID":0},"Burst D":{"fileID":0},"Burst E":{"fileID":0},"Burst F":{"fileID":0},"Burst G":{"fileID":0},"Final Burst":{"fileID":0},"Trobbio":{"fileID":2472}}}`

全局迁移：`[]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1563432>)

出口：FINISHED → Idle。isSequence=0。

1. `FindNamedChild(gameObject="Self", storeResult="$Bursts")`

2. `FindNamedChild(gameObject="Owner($Bursts)", storeResult="$Burst A")`

3. `FindNamedChild(gameObject="Owner($Bursts)", storeResult="$Burst B")`

4. `FindNamedChild(gameObject="Owner($Bursts)", storeResult="$Burst C")`

5. `FindNamedChild(gameObject="Owner($Bursts)", storeResult="$Burst D")`

6. `FindNamedChild(gameObject="Owner($Bursts)", storeResult="$Burst E")`

7. `FindNamedChild(gameObject="Owner($Bursts)", storeResult="$Burst F")`

8. `FindNamedChild(gameObject="Owner($Bursts)", storeResult="$Burst G")`

9. `ActivateAllChildren(gameObject="$Bursts", activate=false)`



#### Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1563647>)

出口：ATTACK → Shift X Pos。isSequence=0。

1. **disabled** `Wait(time=1, finishEvent="ATTACK", realTime=false)`



#### Shift X Pos · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1563720>)

出口：FINISHED → Trob Choice。isSequence=0。

1. `RandomFloat(min=-1.2, max=1.2, storeResult="$Shift X")`

2. `SetPosition2d(gameObject="Owner($Bursts)", vector="None", x="$Shift X", y="None", space=1, everyFrame=false, lateUpdate=false)`

3. `NextFrameEvent(sendEvent="FINISHED")`



#### Trob Choice · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1563843>)

出口：L → Trob L；M → Trob M；R → Trob R；MID L → Mid L；MID R → Mid R。isSequence=0。

1. **disabled** `SendEvent(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="M", delay=0, everyFrame=false)`

2. **disabled** `SendRandomEvent(events=["L","R"], weights=[0.5,0.5], delay=0)`

3. `SendRandomEventV4(events=["L","M","R","MID L","MID R"], weights=[1,1,1,1,1], eventMax=[1,1,1,1,1], missedMax=[6,6,6,6,6], activeBool="None")`



#### Trob L · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1564148>)

出口：PTN 1 → L Ptn 1；PTN 2 → L Ptn 2。isSequence=0。

1. `SetGameObject(variable="$Final Burst", gameObject="$Burst C", everyFrame=false)`

2. `SetFsmGameObject(gameObject="Owner($Trobbio)", fsmName="Control", variableName="Final Burst", setValue="$Burst C", everyFrame=false)`

3. **disabled** `SendEvent(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="PTN 2", delay=0, everyFrame=false)`

4. `SendRandomEventV4(events=["PTN 1","PTN 2"], weights=[1,1], eventMax=[1,1], missedMax=[2,2], activeBool="None")`



#### L Ptn 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1564376>)

出口：FINISHED → Final Burst。isSequence=0。

1. **disabled** `RandomFloat(min="$Delay Min", max="$Delay Max", storeResult="$Delay 1")`

2. `ActivateGameObjectDelay(gameObject="Owner($Burst A)", activate=1, resetOnExit=false, delay="$Delay Min")`

3. `RandomFloat(min="$Delay Min", max="$Delay Max", storeResult="$Delay 2")`

4. `ActivateGameObjectDelay(gameObject="Owner($Burst D)", activate=1, resetOnExit=false, delay="$Delay 2")`

5. **disabled** `RandomFloat(min="$Delay Min", max="$Delay Max", storeResult="$Delay 3")`

6. `ActivateGameObjectDelay(gameObject="Owner($Burst E)", activate=1, resetOnExit=false, delay="$Delay Max")`

7. `RandomFloat(min="$Delay Min", max="$Delay Max", storeResult="$Delay 4")`

8. `ActivateGameObjectDelay(gameObject="Owner($Burst G)", activate=1, resetOnExit=false, delay="$Delay 4")`

9. `Wait(time=1.25, finishEvent="FINISHED", realTime=false)`



#### Final Burst · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1564645>)

出口：FINISHED → Idle；ATTACK → Quick Reset。isSequence=0。

1. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Trobbio)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="FINAL BURST", delay=0, everyFrame=false)`

2. `ActivateGameObject(gameObject="Owner($Final Burst)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

3. `Wait(time=2, finishEvent="FINISHED", realTime=false)`



#### Quick Reset · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1564804>)

出口：FINISHED → Shift X Pos。isSequence=0。

1. `ActivateAllChildren(gameObject="$Bursts", activate=false)`



#### Trob R · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1564875>)

出口：PTN 1 → R Ptn 1；PTN 2 → R Ptn 2。isSequence=0。

1. `SetGameObject(variable="$Final Burst", gameObject="$Burst E", everyFrame=false)`

2. `SetFsmGameObject(gameObject="Owner($Trobbio)", fsmName="Control", variableName="Final Burst", setValue="$Burst E", everyFrame=false)`

3. **disabled** `SendEvent(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="PTN 1", delay=0, everyFrame=false)`

4. `SendRandomEventV4(events=["PTN 1","PTN 2"], weights=[1,1], eventMax=[1,1], missedMax=[2,2], activeBool="None")`



#### R Ptn 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1565103>)

出口：FINISHED → Final Burst。isSequence=0。

1. **disabled** `RandomFloat(min="$Delay Min", max="$Delay Max", storeResult="$Delay 1")`

2. `ActivateGameObjectDelay(gameObject="Owner($Burst G)", activate=1, resetOnExit=false, delay="$Delay Min")`

3. `RandomFloat(min="$Delay Min", max="$Delay Max", storeResult="$Delay 2")`

4. `ActivateGameObjectDelay(gameObject="Owner($Burst D)", activate=1, resetOnExit=false, delay="$Delay 2")`

5. **disabled** `RandomFloat(min="$Delay Min", max="$Delay Max", storeResult="$Delay 3")`

6. `ActivateGameObjectDelay(gameObject="Owner($Burst C)", activate=1, resetOnExit=false, delay="$Delay Max")`

7. `RandomFloat(min="$Delay Min", max="$Delay Max", storeResult="$Delay 4")`

8. `ActivateGameObjectDelay(gameObject="Owner($Burst A)", activate=1, resetOnExit=false, delay="$Delay 4")`

9. `Wait(time=1.25, finishEvent="FINISHED", realTime=false)`



#### L Ptn 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1565372>)

出口：FINISHED → Final Burst。isSequence=0。

1. `RandomFloat(min="$Delay Min", max="$Delay Max", storeResult="$Delay 1")`

2. `ActivateGameObjectDelay(gameObject="Owner($Burst B)", activate=1, resetOnExit=false, delay="$Delay 1")`

3. `RandomFloat(min="$Delay Min", max="$Delay Max", storeResult="$Delay 2")`

4. `ActivateGameObjectDelay(gameObject="Owner($Burst D)", activate=1, resetOnExit=false, delay="$Delay 2")`

5. **disabled** `RandomFloat(min="$Delay Min", max="$Delay Max", storeResult="$Delay 3")`

6. `ActivateGameObjectDelay(gameObject="Owner($Burst F)", activate=1, resetOnExit=false, delay="$Delay Max")`

7. **disabled** `RandomFloat(min="$Delay Min", max="$Delay Max", storeResult="$Delay 4")`

8. `ActivateGameObjectDelay(gameObject="Owner($Burst G)", activate=1, resetOnExit=false, delay="$Delay Min")`

9. `Wait(time=1.25, finishEvent="FINISHED", realTime=false)`



#### R Ptn 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1565641>)

出口：FINISHED → Final Burst。isSequence=0。

1. `RandomFloat(min="$Delay Min", max="$Delay Max", storeResult="$Delay 1")`

2. `ActivateGameObjectDelay(gameObject="Owner($Burst F)", activate=1, resetOnExit=false, delay="$Delay 1")`

3. `RandomFloat(min="$Delay Min", max="$Delay Max", storeResult="$Delay 2")`

4. `ActivateGameObjectDelay(gameObject="Owner($Burst D)", activate=1, resetOnExit=false, delay="$Delay 2")`

5. **disabled** `RandomFloat(min="$Delay Min", max="$Delay Max", storeResult="$Delay 3")`

6. `ActivateGameObjectDelay(gameObject="Owner($Burst B)", activate=1, resetOnExit=false, delay="$Delay Max")`

7. **disabled** `RandomFloat(min="$Delay Min", max="$Delay Max", storeResult="$Delay 4")`

8. `ActivateGameObjectDelay(gameObject="Owner($Burst A)", activate=1, resetOnExit=false, delay="$Delay Min")`

9. `Wait(time=1.25, finishEvent="FINISHED", realTime=false)`



#### Trob M · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1565910>)

出口：PTN 1 → M Ptn 1；PTN 2 → M Ptn 2。isSequence=0。

1. `SetGameObject(variable="$Final Burst", gameObject="$Burst D", everyFrame=false)`

2. `SetFsmGameObject(gameObject="Owner($Trobbio)", fsmName="Control", variableName="Final Burst", setValue="$Burst D", everyFrame=false)`

3. **disabled** `SendEvent(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="PTN 1", delay=0, everyFrame=false)`

4. `SendRandomEventV4(events=["PTN 1","PTN 2"], weights=[1,1], eventMax=[1,1], missedMax=[2,2], activeBool="None")`



#### M Ptn 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1566138>)

出口：FINISHED → Final Burst。isSequence=0。

1. **disabled** `RandomFloat(min="$Delay Min", max="$Delay Max", storeResult="$Delay 1")`

2. `ActivateGameObjectDelay(gameObject="Owner($Burst A)", activate=1, resetOnExit=false, delay="$Delay Min")`

3. `RandomFloat(min="$Delay Min", max="$Delay Max", storeResult="$Delay 2")`

4. `ActivateGameObjectDelay(gameObject="Owner($Burst B)", activate=1, resetOnExit=false, delay=0.5)`

5. **disabled** `RandomFloat(min="$Delay Min", max="$Delay Max", storeResult="$Delay 3")`

6. `ActivateGameObjectDelay(gameObject="Owner($Burst F)", activate=1, resetOnExit=false, delay=0.75)`

7. `RandomFloat(min="$Delay Min", max="$Delay Max", storeResult="$Delay 4")`

8. `ActivateGameObjectDelay(gameObject="Owner($Burst G)", activate=1, resetOnExit=false, delay="$Delay Min")`

9. `Wait(time=1.25, finishEvent="FINISHED", realTime=false)`



#### M Ptn 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1566407>)

出口：FINISHED → Final Burst。isSequence=0。

1. `RandomFloat(min="$Delay Min", max="$Delay Max", storeResult="$Delay 1")`

2. `ActivateGameObjectDelay(gameObject="Owner($Burst A)", activate=1, resetOnExit=false, delay="$Delay 1")`

3. `RandomFloat(min="$Delay Min", max="$Delay Max", storeResult="$Delay 2")`

4. `ActivateGameObjectDelay(gameObject="Owner($Burst C)", activate=1, resetOnExit=false, delay="$Delay 2")`

5. `RandomFloat(min="$Delay Min", max="$Delay Max", storeResult="$Delay 3")`

6. `ActivateGameObjectDelay(gameObject="Owner($Burst E)", activate=1, resetOnExit=false, delay="$Delay Min")`

7. `RandomFloat(min="$Delay Min", max="$Delay Max", storeResult="$Delay 4")`

8. `ActivateGameObjectDelay(gameObject="Owner($Burst G)", activate=1, resetOnExit=false, delay="$Delay 4")`

9. `Wait(time=1.25, finishEvent="FINISHED", realTime=false)`



#### Mid L · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1566676>)

出口：FINISHED → Final Burst。isSequence=0。

1. `SetGameObject(variable="$Final Burst", gameObject="$Burst B", everyFrame=false)`

2. `SetFsmGameObject(gameObject="Owner($Trobbio)", fsmName="Control", variableName="Final Burst", setValue="$Burst B", everyFrame=false)`

3. **disabled** `RandomFloat(min="$Delay Min", max="$Delay Max", storeResult="$Delay 1")`

4. `ActivateGameObjectDelay(gameObject="Owner($Burst A)", activate=1, resetOnExit=false, delay="$Delay Min")`

5. `RandomFloat(min="$Delay Min", max="$Delay Max", storeResult="$Delay 2")`

6. `ActivateGameObjectDelay(gameObject="Owner($Burst D)", activate=1, resetOnExit=false, delay="$Delay 2")`

7. `RandomFloat(min="$Delay Min", max="$Delay Max", storeResult="$Delay 3")`

8. `ActivateGameObjectDelay(gameObject="Owner($Burst E)", activate=1, resetOnExit=false, delay="$Delay 3")`

9. `RandomFloat(min="$Delay Min", max="$Delay Max", storeResult="$Delay 4")`

10. `ActivateGameObjectDelay(gameObject="Owner($Burst G)", activate=1, resetOnExit=false, delay="$Delay 4")`

11. `Wait(time=1.25, finishEvent="FINISHED", realTime=false)`



#### Mid R · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1566995>)

出口：FINISHED → Final Burst。isSequence=0。

1. `SetGameObject(variable="$Final Burst", gameObject="$Burst F", everyFrame=false)`

2. `SetFsmGameObject(gameObject="Owner($Trobbio)", fsmName="Control", variableName="Final Burst", setValue="$Burst F", everyFrame=false)`

3. **disabled** `RandomFloat(min="$Delay Min", max="$Delay Max", storeResult="$Delay 1")`

4. `ActivateGameObjectDelay(gameObject="Owner($Burst G)", activate=1, resetOnExit=false, delay="$Delay Min")`

5. `RandomFloat(min="$Delay Min", max="$Delay Max", storeResult="$Delay 2")`

6. `ActivateGameObjectDelay(gameObject="Owner($Burst D)", activate=1, resetOnExit=false, delay="$Delay 2")`

7. `RandomFloat(min="$Delay Min", max="$Delay Max", storeResult="$Delay 3")`

8. `ActivateGameObjectDelay(gameObject="Owner($Burst C)", activate=1, resetOnExit=false, delay="$Delay 3")`

9. `RandomFloat(min="$Delay Min", max="$Delay Max", storeResult="$Delay 4")`

10. `ActivateGameObjectDelay(gameObject="Owner($Burst A)", activate=1, resetOnExit=false, delay="$Delay 4")`

11. `Wait(time=1.25, finishEvent="FINISHED", realTime=false)`



### Spotlight R / FSM [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1570436>)

变量初值：`{"floatVariables":{"Angle":0,"Scan Min":225.322,"Scan Max":294.948,"Start Angle":0},"boolVariables":{"Scan L":0},"gameObjectVariables":{"Target":{"fileID":2472}}}`

全局迁移：`[{"fsmEvent":{"name":"FOLLOW HERO","isSystemEvent":0,"isGlobal":0},"toState":"Follow Hero","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0},{"fsmEvent":{"name":"FOLLOW","isSystemEvent":0,"isGlobal":0},"toState":"Follow","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0},{"fsmEvent":{"name":"SCAN","isSystemEvent":0,"isGlobal":0},"toState":"Scan Dir","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0},{"fsmEvent":{"name":"TROBBIO KILLED","isSystemEvent":0,"isGlobal":0},"toState":"Follow","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0},{"fsmEvent":{"name":"END","isSystemEvent":0,"isGlobal":0},"toState":"Inert","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0}]`

#### Inert · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1570453>)

出口：无本地迁移（持续/外部驱动）。isSequence=0。



#### Follow · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1570505>)

出口：无本地迁移（持续/外部驱动）。isSequence=0。

1. `GetAngleToTarget2D(gameObject="Self", target="$Target", offsetX=0, offsetY=0, storeAngle="$Angle", pause=0, everyFrame=true)`

2. `RotateTo(gameObject="Self", targetAngle="$Angle", speed=55)`



#### Follow Hero · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1570629>)

出口：无本地迁移（持续/外部驱动）。isSequence=0。

1. `GetAngleToTarget2D(gameObject="Self", target="$Hero", offsetX=0, offsetY=0, storeAngle="$Angle", pause=0, everyFrame=true)`

2. `RotateTo(gameObject="Self", targetAngle="$Angle", speed=55)`



#### Scan Dir · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1570753>)

出口：L → Scan L；R → Scan R。isSequence=0。

1. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="FADE UP", delay=0, everyFrame=false)`

2. `BoolTest(boolVariable="$Scan L", isTrue="L", isFalse="R", everyFrame=false)`



#### Scan L · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1570887>)

出口：FINISHED → Scan R。isSequence=0。

1. `GetRotation(gameObject="Self", quaternion="None", vector="None", xAngle="None", yAngle="None", zAngle="$Start Angle", space=0, everyFrame=false)`

2. `EaseFloat(fromValue="$Start Angle", toValue="$Scan Min", floatVariable="$Angle", time=1, speed="None", delay="None", easeType=2, reverse=0, finishEvent="FINISHED", realTime=false)`

3. `SetRotation(gameObject="Self", quaternion="None", vector="None", xAngle="None", yAngle="None", zAngle="$Angle", space=0, everyFrame=true, lateUpdate=false)`



#### Scan R · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1571100>)

出口：FINISHED → Scan L。isSequence=0。

1. `GetRotation(gameObject="Self", quaternion="None", vector="None", xAngle="None", yAngle="None", zAngle="$Start Angle", space=0, everyFrame=false)`

2. `EaseFloat(fromValue="$Start Angle", toValue="$Scan Max", floatVariable="$Angle", time=1, speed="None", delay="None", easeType=2, reverse=0, finishEvent="FINISHED", realTime=false)`

3. `SetRotation(gameObject="Self", quaternion="None", vector="None", xAngle="None", yAngle="None", zAngle="$Angle", space=0, everyFrame=true, lateUpdate=false)`



### Spotlight R / Fade [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1571487>)

变量初值：`{}`

全局迁移：`[{"fsmEvent":{"name":"FADE DOWN","isSystemEvent":0,"isGlobal":0},"toState":"Down","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0}]`

#### Down · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1571504>)

出口：FADE UP → Up。isSequence=0。

1. `FadeNestedFadeGroup(Target="Self", ToAlpha=0, FadeTime=0.5)`



#### Up · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1571590>)

出口：FADE DOWN → Down。isSequence=0。

1. `FadeNestedFadeGroup(Target="Self", ToAlpha=1, FadeTime=0.5)`



### Confetti Shooters / Control [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1571815>)

变量初值：`{}`

全局迁移：`[]`

#### Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1571832>)

出口：PLAY → Play Pause。isSequence=0。



#### Play · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1571893>)

出口：FINISHED → Idle。isSequence=0。

1. `PlayParticleEmitterChildren(gameObject="Self", resetTimeIfPlaying=false, stopOnStateExit=false)`



#### Play Pause · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1571967>)

出口：FINISHED → Play。isSequence=0。

1. `Wait(time=0.5, finishEvent="FINISHED", realTime=false)`



### Battle Gate (1) / BG Control [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1572118>)

变量初值：`{"boolVariables":{"Start Closed":0},"gameObjectVariables":{"Plat Dust":{"fileID":2747},"Plat Stream Dust":{"fileID":1757},"Raise Dust":{"fileID":0},"Self":{"fileID":0},"Slam Effect":{"fileID":2577},"Wall Collider":{"fileID":1689}}}`

全局迁移：`[{"fsmEvent":{"name":"BG DESTROY","isSystemEvent":0,"isGlobal":0},"toState":"Destroy","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0},{"fsmEvent":{"name":"BG QUICK OPEN","isSystemEvent":0,"isGlobal":0},"toState":"Quick Open","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0}]`

#### Opened · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1572135>)

出口：BG CLOSE → Close 1；BG QUICK CLOSE → Quick Close。isSequence=0。

1. `GetOwner(storeGameObject="$Self")`

2. `BoolTest(boolVariable="$Start Closed", isTrue="BG QUICK CLOSE", isFalse=null, everyFrame=false)`

3. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="BG Opened")`

4. `SetCollider(gameObject="Self", active=false, resetOnExit=false)`

5. `FindNamedChild(gameObject="Self", storeResult="$Wall Collider")`

6. `ActivateGameObject(gameObject="Owner($Wall Collider)", activate=false, recursive=false, resetOnExit=false, everyFrame=false)`



#### Close 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1572291>)

出口：FINISHED → Close 2。isSequence=0。

1. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:b44b5e36561bf614a8b8ec08a45972dc#8300000", pitchMin=0.800000011920929, pitchMax=1.2000000476837158, volume=0.5, delay=0.0, storePlayer="fileID:0")`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="BG Close 1", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `SetCollider(gameObject="Self", active=true, resetOnExit=false)`

4. `PlayParticleEmitter(gameObject="Owner($Plat Dust)", emit=0, resetIfPlaying=false)`

5. `SetMeshRenderer(gameObject="Self", active=true)`

6. `ActivateGameObject(gameObject="Owner($Wall Collider)", activate=true, recursive=false, resetOnExit=false, everyFrame=false)`



#### Close 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1572460>)

出口：BG OPEN → Open。isSequence=0。

1. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="BG Close 2")`

2. `DoCameraShakeV2(Target="Self", MaxCameraDistance="None", Camera="GUID:9b0888e0916dca544846a2f34304dac9#11400000", Profile="GUID:279f38013a080f34999cd00fbee1b9c2#11400000", DoFreeze=false, Delay=0.0, CancelOnExit=false)`

3. `ActivateGameObject(gameObject="Owner($Slam Effect)", activate=true, recursive=false, resetOnExit=false, everyFrame=false)`



#### Open · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1572592>)

出口：BG CLOSE → Close 1；BG QUICK CLOSE → Quick Close；FINISHED → Finish Open。isSequence=0。

1. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:eabfebdb7ddb02145aee45d85b14430a#8300000", pitchMin=1.0, pitchMax=1.0, volume=0.8500000238418579, delay=0.0, storePlayer="fileID:0")`

2. `PlayParticleEmitter(gameObject="Owner($Plat Stream Dust)", emit=0, resetIfPlaying=false)`

3. `SetCollider(gameObject="Self", active=false, resetOnExit=false)`

4. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="BG Open", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

5. `ActivateGameObject(gameObject="Owner($Wall Collider)", activate=false, recursive=false, resetOnExit=false, everyFrame=false)`



#### Quick Close · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1572767>)

出口：BG OPEN → Open；FINISHED → Double Close。isSequence=0。

1. `SetCollider(gameObject="Self", active=true, resetOnExit=false)`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="BG Closed")`

3. `Wait(time=0.20000000298023224, finishEvent="FINISHED", realTime=false)`

4. `SetMeshRenderer(gameObject="Self", active=true)`

5. `ActivateGameObject(gameObject="Owner($Wall Collider)", activate=true, recursive=false, resetOnExit=false, everyFrame=false)`



#### Double Close · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1572907>)

出口：BG OPEN → Open。isSequence=0。

1. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="BG Closed")`



#### Destroy · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1572993>)

出口：无本地迁移（持续/外部驱动）。isSequence=0。

1. `DestroySelf(detachChildren=false)`



#### Quick Open · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1573048>)

出口：BG CLOSE → Close 1；BG QUICK CLOSE → Quick Close。isSequence=0。

1. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="BG Opened")`

2. `SetCollider(gameObject="Self", active=false, resetOnExit=false)`

3. `ActivateGameObject(gameObject="Owner($Wall Collider)", activate=false, recursive=false, resetOnExit=false, everyFrame=false)`



#### Finish Open · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1573171>)

出口：BG CLOSE → Close 1；BG QUICK CLOSE → Quick Close。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=false)`

2. `SendEventByName(eventTarget={"target":2,"excludeSelf":0,"gameObject":"Owner($CameraParent)","fsmName":"CameraShake","sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="EnemyKillShake", delay=0.0, everyFrame=false)`



### Flare Glitter / Control [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1590536>)

变量初值：`{"floatVariables":{"Shift X":0,"Pos Y":0,"Low Min Y":16,"Low Max Y":17,"High Min Y":20.5,"High Max Y":23,"Top Y":23,"Low Buddy X":0},"intVariables":{"Skip":0},"boolVariables":{"Low Buddy A":0,"Active":0},"gameObjectVariables":{"Pt Ambient":{"fileID":0},"Flare Glitter 1":{"fileID":0},"Flare Glitter 2":{"fileID":0},"Flare Glitter 3":{"fileID":0},"Flare Glitter 4":{"fileID":0},"Flare Glitter 5":{"fileID":0},"Next Glitter":{"fileID":0},"Flare Glitter 6":{"fileID":0}},"arrayVariables":{"Flare Glitters":null}}`

全局迁移：`[]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1590553>)

出口：FINISHED → Build Array。isSequence=0。

1. `FindNamedChild(gameObject="Self", storeResult="$Pt Ambient")`

2. `FindNamedChild(gameObject="Self", storeResult="$Flare Glitter 1")`

3. `FindNamedChild(gameObject="Self", storeResult="$Flare Glitter 2")`

4. `FindNamedChild(gameObject="Self", storeResult="$Flare Glitter 3")`

5. `FindNamedChild(gameObject="Self", storeResult="$Flare Glitter 4")`

6. `FindNamedChild(gameObject="Self", storeResult="$Flare Glitter 5")`

7. `FindNamedChild(gameObject="Self", storeResult="$Flare Glitter 6")`

8. `Wait(time=1, finishEvent="FINISHED", realTime=false)`



#### Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1590752>)

出口：FLARE GLITTER → Antic；FLARE GLITTER INTRO → Intro Glitter；FINAL FLARE → Final Flare 1。isSequence=0。

1. **disabled** `Wait(time=3, finishEvent="FLARE GLITTER", realTime=false)`

2. `SetBoolValue(boolVariable="$Active", boolValue=0, everyFrame=false)`



#### Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1590860>)

出口：FINISHED → Ptn。isSequence=0。

1. **disabled** `RandomFloat(min=-1.5, max=1.5, storeResult="$Shift X")`

2. **disabled** `SetPosition(gameObject="Self", vector="None", x="$Shift X", y="None", z="None", space=0, everyFrame=false, lateUpdate=false)`

3. `SetBoolValue(boolVariable="$Active", boolValue=1, everyFrame=false)`

4. `PlayParticleEmitter(gameObject="Owner($Pt Ambient)", emit="None", resetIfPlaying=true)`

5. `Wait(time=0.5, finishEvent="FINISHED", realTime=false)`



#### Ptn · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1591034>)

出口：PTN 1 → Pt1 Low 1；PTN 2 → High 4。isSequence=0。

1. **disabled** `RandomInt(min=1, max=6, storeResult="$Skip", inclusiveMax=true, noRepeat=0)`

2. `SetIntValue(intVariable="$Skip", intValue=0, everyFrame=false)`

3. `RandomBool(storeResult="$Low Buddy A")`

4. `ArrayShuffle(array={"useVariable":1,"name":"Flare Glitters","tooltip":null,"showInInspector":0,"networkSync":0,"type":3,"objectTypeName":"UnityEngine.GameObject","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}, startIndex="None", shufflingRange="None")`

5. **disabled** `SendEvent(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="PTN 1", delay=0, everyFrame=false)`

6. `SendRandomEvent(events=["PTN 1","PTN 2"], weights=[0.5,0.5], delay=0)`



#### Pt1 Low 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1591267>)

出口：FINISHED → Pt1 Low Buddy A。isSequence=0。

1. `IntCompare(integer1="$Skip", integer2=1, equal="FINISHED", lessThan=null, greaterThan=null, everyFrame=false)`

2. `ArrayGet(array={"useVariable":1,"name":"Flare Glitters","tooltip":null,"showInInspector":0,"networkSync":0,"type":3,"objectTypeName":"UnityEngine.GameObject","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}, index=0, storeValue={"variableName":"Next Glitter","objectType":"UnityEngine.GameObject","useVariable":1,"type":3,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}, everyFrame=false, indexOutOfRange=null)`

3. `RandomFloat(min="$Low Min Y", max="$Low Max Y", storeResult="$Pos Y")`

4. `SetPosition(gameObject="Owner($Next Glitter)", vector="None", x="None", y="$Pos Y", z="None", space=0, everyFrame=false, lateUpdate=false)`

5. `ActivateGameObject(gameObject="Owner($Next Glitter)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

6. `WaitRandom(timeMin=0.15, timeMax=0.25, finishEvent="FINISHED", realTime=false)`



#### Build Array · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1591513>)

出口：FINISHED → Idle。isSequence=0。

1. `ArrayAdd(array={"useVariable":1,"name":"Flare Glitters","tooltip":null,"showInInspector":0,"networkSync":0,"type":3,"objectTypeName":"UnityEngine.GameObject","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}, value={"variableName":"Flare Glitter 1","objectType":"UnityEngine.GameObject","useVariable":1,"type":3,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`

2. `ArrayAdd(array={"useVariable":1,"name":"Flare Glitters","tooltip":null,"showInInspector":0,"networkSync":0,"type":3,"objectTypeName":"UnityEngine.GameObject","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}, value={"variableName":"Flare Glitter 2","objectType":"UnityEngine.GameObject","useVariable":1,"type":3,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`

3. `ArrayAdd(array={"useVariable":1,"name":"Flare Glitters","tooltip":null,"showInInspector":0,"networkSync":0,"type":3,"objectTypeName":"UnityEngine.GameObject","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}, value={"variableName":"Flare Glitter 3","objectType":"UnityEngine.GameObject","useVariable":1,"type":3,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`

4. `ArrayAdd(array={"useVariable":1,"name":"Flare Glitters","tooltip":null,"showInInspector":0,"networkSync":0,"type":3,"objectTypeName":"UnityEngine.GameObject","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}, value={"variableName":"Flare Glitter 4","objectType":"UnityEngine.GameObject","useVariable":1,"type":3,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`

5. **disabled** `ArrayAdd(array={"useVariable":1,"name":"Flare Glitters","tooltip":null,"showInInspector":0,"networkSync":0,"type":3,"objectTypeName":"UnityEngine.GameObject","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}, value={"variableName":"Flare Glitter 5","objectType":"UnityEngine.GameObject","useVariable":1,"type":3,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`

6. **disabled** `ArrayAdd(array={"useVariable":1,"name":"Flare Glitters","tooltip":null,"showInInspector":0,"networkSync":0,"type":3,"objectTypeName":"UnityEngine.GameObject","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}, value={"variableName":"Flare Glitter 6","objectType":"UnityEngine.GameObject","useVariable":1,"type":3,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`



#### Pt1 High 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1591820>)

出口：FINISHED → Pt1 Low 2。isSequence=0。

1. `IntCompare(integer1="$Skip", integer2=2, equal="FINISHED", lessThan=null, greaterThan=null, everyFrame=false)`

2. `ArrayGet(array={"useVariable":1,"name":"Flare Glitters","tooltip":null,"showInInspector":0,"networkSync":0,"type":3,"objectTypeName":"UnityEngine.GameObject","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}, index=1, storeValue={"variableName":"Next Glitter","objectType":"UnityEngine.GameObject","useVariable":1,"type":3,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}, everyFrame=false, indexOutOfRange=null)`

3. `RandomFloat(min="$High Min Y", max="$High Max Y", storeResult="$Pos Y")`

4. `SetPosition(gameObject="Owner($Next Glitter)", vector="None", x="None", y="$Pos Y", z="None", space=0, everyFrame=false, lateUpdate=false)`

5. `ActivateGameObject(gameObject="Owner($Next Glitter)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

6. `WaitRandom(timeMin=0.15, timeMax=0.25, finishEvent="FINISHED", realTime=false)`



#### Pt1 Low 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1592066>)

出口：FINISHED → Pt1 Low Buddy B。isSequence=0。

1. `IntCompare(integer1="$Skip", integer2=3, equal="FINISHED", lessThan=null, greaterThan=null, everyFrame=false)`

2. `ArrayGet(array={"useVariable":1,"name":"Flare Glitters","tooltip":null,"showInInspector":0,"networkSync":0,"type":3,"objectTypeName":"UnityEngine.GameObject","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}, index=2, storeValue={"variableName":"Next Glitter","objectType":"UnityEngine.GameObject","useVariable":1,"type":3,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}, everyFrame=false, indexOutOfRange=null)`

3. `RandomFloat(min="$Low Min Y", max="$Low Max Y", storeResult="$Pos Y")`

4. `SetPosition(gameObject="Owner($Next Glitter)", vector="None", x="None", y="$Pos Y", z="None", space=0, everyFrame=false, lateUpdate=false)`

5. `ActivateGameObject(gameObject="Owner($Next Glitter)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

6. `WaitRandom(timeMin=0.15, timeMax=0.25, finishEvent="FINISHED", realTime=false)`



#### Pt1 High 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1592312>)

出口：FINISHED → Pt1 Low Buddy 1。isSequence=0。

1. `IntCompare(integer1="$Skip", integer2=4, equal="FINISHED", lessThan=null, greaterThan=null, everyFrame=false)`

2. `ArrayGet(array={"useVariable":1,"name":"Flare Glitters","tooltip":null,"showInInspector":0,"networkSync":0,"type":3,"objectTypeName":"UnityEngine.GameObject","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}, index=3, storeValue={"variableName":"Next Glitter","objectType":"UnityEngine.GameObject","useVariable":1,"type":3,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}, everyFrame=false, indexOutOfRange=null)`

3. `RandomFloat(min="$High Min Y", max="$High Max Y", storeResult="$Pos Y")`

4. `SetPosition(gameObject="Owner($Next Glitter)", vector="None", x="None", y="$Pos Y", z="None", space=0, everyFrame=false, lateUpdate=false)`

5. `ActivateGameObject(gameObject="Owner($Next Glitter)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

6. `WaitRandom(timeMin=0.15, timeMax=0.25, finishEvent="FINISHED", realTime=false)`



#### Low 3 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1592558>)

出口：FINISHED → Pt2 Low Buddy B。isSequence=0。

1. `IntCompare(integer1="$Skip", integer2=4, equal="FINISHED", lessThan=null, greaterThan=null, everyFrame=false)`

2. `ArrayGet(array={"useVariable":1,"name":"Flare Glitters","tooltip":null,"showInInspector":0,"networkSync":0,"type":3,"objectTypeName":"UnityEngine.GameObject","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}, index=3, storeValue={"variableName":"Next Glitter","objectType":"UnityEngine.GameObject","useVariable":1,"type":3,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}, everyFrame=false, indexOutOfRange=null)`

3. `RandomFloat(min="$Low Min Y", max="$Low Max Y", storeResult="$Pos Y")`

4. `SetPosition(gameObject="Owner($Next Glitter)", vector="None", x="None", y="$Pos Y", z="None", space=0, everyFrame=false, lateUpdate=false)`

5. `ActivateGameObject(gameObject="Owner($Next Glitter)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

6. `WaitRandom(timeMin=0.15, timeMax=0.25, finishEvent="FINISHED", realTime=false)`



#### High 3 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1592804>)

出口：FINISHED → Low 3。isSequence=0。

1. `IntCompare(integer1="$Skip", integer2=3, equal="FINISHED", lessThan=null, greaterThan=null, everyFrame=false)`

2. `ArrayGet(array={"useVariable":1,"name":"Flare Glitters","tooltip":null,"showInInspector":0,"networkSync":0,"type":3,"objectTypeName":"UnityEngine.GameObject","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}, index=2, storeValue={"variableName":"Next Glitter","objectType":"UnityEngine.GameObject","useVariable":1,"type":3,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}, everyFrame=false, indexOutOfRange=null)`

3. `RandomFloat(min="$High Min Y", max="$High Max Y", storeResult="$Pos Y")`

4. `SetPosition(gameObject="Owner($Next Glitter)", vector="None", x="None", y="$Pos Y", z="None", space=0, everyFrame=false, lateUpdate=false)`

5. `ActivateGameObject(gameObject="Owner($Next Glitter)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

6. `WaitRandom(timeMin=0.15, timeMax=0.25, finishEvent="FINISHED", realTime=false)`



#### Low 4 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1593050>)

出口：FINISHED → Pt2 Low Buddy A。isSequence=0。

1. `IntCompare(integer1="$Skip", integer2=2, equal="FINISHED", lessThan=null, greaterThan=null, everyFrame=false)`

2. `ArrayGet(array={"useVariable":1,"name":"Flare Glitters","tooltip":null,"showInInspector":0,"networkSync":0,"type":3,"objectTypeName":"UnityEngine.GameObject","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}, index=1, storeValue={"variableName":"Next Glitter","objectType":"UnityEngine.GameObject","useVariable":1,"type":3,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}, everyFrame=false, indexOutOfRange=null)`

3. `RandomFloat(min="$Low Min Y", max="$Low Max Y", storeResult="$Pos Y")`

4. `SetPosition(gameObject="Owner($Next Glitter)", vector="None", x="None", y="$Pos Y", z="None", space=0, everyFrame=false, lateUpdate=false)`

5. `ActivateGameObject(gameObject="Owner($Next Glitter)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

6. `WaitRandom(timeMin=0.15, timeMax=0.25, finishEvent="FINISHED", realTime=false)`



#### High 4 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1593296>)

出口：FINISHED → Low 4。isSequence=0。

1. `IntCompare(integer1="$Skip", integer2=1, equal="FINISHED", lessThan=null, greaterThan=null, everyFrame=false)`

2. `ArrayGet(array={"useVariable":1,"name":"Flare Glitters","tooltip":null,"showInInspector":0,"networkSync":0,"type":3,"objectTypeName":"UnityEngine.GameObject","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}, index=0, storeValue={"variableName":"Next Glitter","objectType":"UnityEngine.GameObject","useVariable":1,"type":3,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}, everyFrame=false, indexOutOfRange=null)`

3. `RandomFloat(min="$High Min Y", max="$High Max Y", storeResult="$Pos Y")`

4. `SetPosition(gameObject="Owner($Next Glitter)", vector="None", x="None", y="$Pos Y", z="None", space=0, everyFrame=false, lateUpdate=false)`

5. `ActivateGameObject(gameObject="Owner($Next Glitter)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

6. `WaitRandom(timeMin=0.15, timeMax=0.25, finishEvent="FINISHED", realTime=false)`



#### Intro Glitter · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1593542>)

出口：FINISHED → Idle。isSequence=0。

1. `PlayParticleEmitter(gameObject="Owner($Pt Ambient)", emit="None", resetIfPlaying=true)`



#### Final Flare 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1593622>)

出口：FINISHED → Final Flare 2。isSequence=0。

1. `RandomFloat(min="$High Min Y", max="$High Max Y", storeResult="$Pos Y")`

2. `SetGameObject(variable="$Next Glitter", gameObject="$Flare Glitter 2", everyFrame=false)`

3. `SetPosition(gameObject="Owner($Next Glitter)", vector="None", x="None", y="$Pos Y", z="None", space=0, everyFrame=false, lateUpdate=false)`

4. `ActivateGameObject(gameObject="Owner($Next Glitter)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

5. `SetFsmBool(gameObject="Owner($Next Glitter)", fsmName="Control", variableName="Nondamaging", setValue=1, everyFrame=false)`

6. `Wait(time=0.5, finishEvent="FINISHED", realTime=false)`



#### Final Flare 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1593837>)

出口：FINISHED → Final Flare 3。isSequence=0。

1. `RandomFloat(min="$High Min Y", max="$High Max Y", storeResult="$Pos Y")`

2. `SetGameObject(variable="$Next Glitter", gameObject="$Flare Glitter 4", everyFrame=false)`

3. `SetPosition(gameObject="Owner($Next Glitter)", vector="None", x="None", y="$Pos Y", z="None", space=0, everyFrame=false, lateUpdate=false)`

4. `ActivateGameObject(gameObject="Owner($Next Glitter)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

5. `SetFsmBool(gameObject="Owner($Next Glitter)", fsmName="Control", variableName="Nondamaging", setValue=1, everyFrame=false)`

6. `Wait(time=0.4, finishEvent="FINISHED", realTime=false)`



#### Final Flare 3 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1594052>)

出口：FINISHED → Final Flare 4。isSequence=0。

1. `RandomFloat(min="$High Min Y", max="$High Max Y", storeResult="$Pos Y")`

2. `SetGameObject(variable="$Next Glitter", gameObject="$Flare Glitter 1", everyFrame=false)`

3. `SetPosition(gameObject="Owner($Next Glitter)", vector="None", x="None", y="$Pos Y", z="None", space=0, everyFrame=false, lateUpdate=false)`

4. `ActivateGameObject(gameObject="Owner($Next Glitter)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

5. `SetFsmBool(gameObject="Owner($Next Glitter)", fsmName="Control", variableName="Nondamaging", setValue=1, everyFrame=false)`

6. `Wait(time=0.4, finishEvent="FINISHED", realTime=false)`



#### Final Flare 4 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1594267>)

出口：FINISHED → Final Flare 5。isSequence=0。

1. `RandomFloat(min="$High Min Y", max="$High Max Y", storeResult="$Pos Y")`

2. `SetGameObject(variable="$Next Glitter", gameObject="$Flare Glitter 3", everyFrame=false)`

3. `SetPosition(gameObject="Owner($Next Glitter)", vector="None", x="None", y="$Pos Y", z="None", space=0, everyFrame=false, lateUpdate=false)`

4. `ActivateGameObject(gameObject="Owner($Next Glitter)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

5. `SetFsmBool(gameObject="Owner($Next Glitter)", fsmName="Control", variableName="Nondamaging", setValue=1, everyFrame=false)`

6. `Wait(time=0.2, finishEvent="FINISHED", realTime=false)`



#### Final Flare 5 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1594482>)

出口：FINISHED → None。isSequence=0。

1. `RandomFloat(min="$High Min Y", max="$High Max Y", storeResult="$Pos Y")`

2. `SetGameObject(variable="$Next Glitter", gameObject="$Flare Glitter 1", everyFrame=false)`

3. `SetPosition(gameObject="Owner($Next Glitter)", vector="None", x="None", y="$Pos Y", z="None", space=0, everyFrame=false, lateUpdate=false)`

4. `ActivateGameObject(gameObject="Owner($Next Glitter)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

5. `SetFsmBool(gameObject="Owner($Next Glitter)", fsmName="Control", variableName="Nondamaging", setValue=1, everyFrame=false)`



#### Pt1 Low 3 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1594685>)

出口：FINISHED → Pt1 High 3。isSequence=0。

1. `IntCompare(integer1="$Skip", integer2=3, equal="FINISHED", lessThan=null, greaterThan=null, everyFrame=false)`

2. `ArrayGet(array={"useVariable":1,"name":"Flare Glitters","tooltip":null,"showInInspector":0,"networkSync":0,"type":3,"objectTypeName":"UnityEngine.GameObject","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}, index=2, storeValue={"variableName":"Next Glitter","objectType":"UnityEngine.GameObject","useVariable":1,"type":3,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}, everyFrame=false, indexOutOfRange=null)`

3. `RandomFloat(min="$Low Min Y", max="$Low Max Y", storeResult="$Pos Y")`

4. `SetPosition(gameObject="Owner($Next Glitter)", vector="None", x="None", y="$Pos Y", z="None", space=0, everyFrame=false, lateUpdate=false)`

5. `ActivateGameObject(gameObject="Owner($Next Glitter)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

6. `WaitRandom(timeMin=0.15, timeMax=0.25, finishEvent="FINISHED", realTime=false)`



#### Pt1 High 3 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1594931>)

出口：FINISHED → Idle。isSequence=0。

1. `IntCompare(integer1="$Skip", integer2=4, equal="FINISHED", lessThan=null, greaterThan=null, everyFrame=false)`

2. `ArrayGet(array={"useVariable":1,"name":"Flare Glitters","tooltip":null,"showInInspector":0,"networkSync":0,"type":3,"objectTypeName":"UnityEngine.GameObject","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}, index=3, storeValue={"variableName":"Next Glitter","objectType":"UnityEngine.GameObject","useVariable":1,"type":3,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}, everyFrame=false, indexOutOfRange=null)`

3. `RandomFloat(min="$High Min Y", max="$High Max Y", storeResult="$Pos Y")`

4. `SetPosition(gameObject="Owner($Next Glitter)", vector="None", x="None", y="$Pos Y", z="None", space=0, everyFrame=false, lateUpdate=false)`

5. `ActivateGameObject(gameObject="Owner($Next Glitter)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

6. `WaitRandom(timeMin=0.15, timeMax=0.25, finishEvent="FINISHED", realTime=false)`



#### Pt1 Low Buddy A · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1595177>)

出口：FINISHED → Pt1 High 1。isSequence=0。

1. `BoolTest(boolVariable="$Low Buddy A", isTrue=null, isFalse="FINISHED", everyFrame=false)`

2. `GetPosition2d(gameObject="Owner($Next Glitter)", vector_2d="None", x="$Low Buddy X", y="None", space=0, everyFrame=false)`



#### Pt1 Low Buddy B · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1595286>)

出口：FINISHED → Pt1 High 2。isSequence=0。

1. `BoolTest(boolVariable="$Low Buddy A", isTrue="FINISHED", isFalse=null, everyFrame=false)`

2. `GetPosition2d(gameObject="Owner($Next Glitter)", vector_2d="None", x="$Low Buddy X", y="None", space=0, everyFrame=false)`



#### Pt1 Low Buddy 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1595395>)

出口：FINISHED → Active Pause。isSequence=0。

1. `RandomFloat(min="$Low Min Y", max="$Low Max Y", storeResult="$Pos Y")`

2. `SetPosition(gameObject="Owner($Flare Glitter 5)", vector="None", x="$Low Buddy X", y="$Top Y", z="None", space=0, everyFrame=false, lateUpdate=false)`

3. `ActivateGameObject(gameObject="Owner($Flare Glitter 5)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

4. `WaitRandom(timeMin=0.15, timeMax=0.25, finishEvent="FINISHED", realTime=false)`



#### Active Pause · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1595567>)

出口：FINISHED → Idle。isSequence=0。

1. `Wait(time=2, finishEvent="FINISHED", realTime=false)`



#### Pt2 Low Buddy A · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1595640>)

出口：FINISHED → High 3。isSequence=0。

1. `BoolTest(boolVariable="$Low Buddy A", isTrue=null, isFalse="FINISHED", everyFrame=false)`

2. `GetPosition2d(gameObject="Owner($Next Glitter)", vector_2d="None", x="$Low Buddy X", y="None", space=0, everyFrame=false)`



#### Pt2 Low Buddy B · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1595749>)

出口：FINISHED → Pt1 Low Buddy 1。isSequence=0。

1. `BoolTest(boolVariable="$Low Buddy A", isTrue="FINISHED", isFalse=null, everyFrame=false)`

2. `GetPosition2d(gameObject="Owner($Next Glitter)", vector_2d="None", x="$Low Buddy X", y="None", space=0, everyFrame=false)`



### Battle Gate / BG Control [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1598209>)

变量初值：`{"boolVariables":{"Start Closed":0},"gameObjectVariables":{"Plat Dust":{"fileID":2749},"Plat Stream Dust":{"fileID":1755},"Raise Dust":{"fileID":0},"Self":{"fileID":0},"Slam Effect":{"fileID":2575},"Wall Collider":{"fileID":1691}}}`

全局迁移：`[{"fsmEvent":{"name":"BG DESTROY","isSystemEvent":0,"isGlobal":0},"toState":"Destroy","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0},{"fsmEvent":{"name":"BG QUICK OPEN","isSystemEvent":0,"isGlobal":0},"toState":"Quick Open","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0}]`

#### Opened · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1598226>)

出口：BG CLOSE → Close 1；BG QUICK CLOSE → Quick Close。isSequence=0。

1. `GetOwner(storeGameObject="$Self")`

2. `BoolTest(boolVariable="$Start Closed", isTrue="BG QUICK CLOSE", isFalse=null, everyFrame=false)`

3. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="BG Opened")`

4. `SetCollider(gameObject="Self", active=false, resetOnExit=false)`

5. `FindNamedChild(gameObject="Self", storeResult="$Wall Collider")`

6. `ActivateGameObject(gameObject="Owner($Wall Collider)", activate=false, recursive=false, resetOnExit=false, everyFrame=false)`



#### Close 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1598382>)

出口：FINISHED → Close 2。isSequence=0。

1. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:b44b5e36561bf614a8b8ec08a45972dc#8300000", pitchMin=0.800000011920929, pitchMax=1.2000000476837158, volume=0.5, delay=0.0, storePlayer="fileID:0")`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="BG Close 1", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `SetCollider(gameObject="Self", active=true, resetOnExit=false)`

4. `PlayParticleEmitter(gameObject="Owner($Plat Dust)", emit=0, resetIfPlaying=false)`

5. `SetMeshRenderer(gameObject="Self", active=true)`

6. `ActivateGameObject(gameObject="Owner($Wall Collider)", activate=true, recursive=false, resetOnExit=false, everyFrame=false)`



#### Close 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1598551>)

出口：BG OPEN → Open。isSequence=0。

1. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="BG Close 2")`

2. `DoCameraShakeV2(Target="Self", MaxCameraDistance="None", Camera="GUID:9b0888e0916dca544846a2f34304dac9#11400000", Profile="GUID:279f38013a080f34999cd00fbee1b9c2#11400000", DoFreeze=false, Delay=0.0, CancelOnExit=false)`

3. `ActivateGameObject(gameObject="Owner($Slam Effect)", activate=true, recursive=false, resetOnExit=false, everyFrame=false)`



#### Open · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1598683>)

出口：BG CLOSE → Close 1；BG QUICK CLOSE → Quick Close；FINISHED → Finish Open。isSequence=0。

1. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:eabfebdb7ddb02145aee45d85b14430a#8300000", pitchMin=1.0, pitchMax=1.0, volume=0.8500000238418579, delay=0.0, storePlayer="fileID:0")`

2. `PlayParticleEmitter(gameObject="Owner($Plat Stream Dust)", emit=0, resetIfPlaying=false)`

3. `SetCollider(gameObject="Self", active=false, resetOnExit=false)`

4. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="BG Open", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

5. `ActivateGameObject(gameObject="Owner($Wall Collider)", activate=false, recursive=false, resetOnExit=false, everyFrame=false)`



#### Quick Close · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1598858>)

出口：BG OPEN → Open；FINISHED → Double Close。isSequence=0。

1. `SetCollider(gameObject="Self", active=true, resetOnExit=false)`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="BG Closed")`

3. `Wait(time=0.20000000298023224, finishEvent="FINISHED", realTime=false)`

4. `SetMeshRenderer(gameObject="Self", active=true)`

5. `ActivateGameObject(gameObject="Owner($Wall Collider)", activate=true, recursive=false, resetOnExit=false, everyFrame=false)`



#### Double Close · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1598998>)

出口：BG OPEN → Open。isSequence=0。

1. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="BG Closed")`



#### Destroy · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1599084>)

出口：无本地迁移（持续/外部驱动）。isSequence=0。

1. `DestroySelf(detachChildren=false)`



#### Quick Open · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1599139>)

出口：BG CLOSE → Close 1；BG QUICK CLOSE → Quick Close。isSequence=0。

1. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="BG Opened")`

2. `SetCollider(gameObject="Self", active=false, resetOnExit=false)`

3. `ActivateGameObject(gameObject="Owner($Wall Collider)", activate=false, recursive=false, resetOnExit=false, everyFrame=false)`



#### Finish Open · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1599262>)

出口：BG CLOSE → Close 1；BG QUICK CLOSE → Quick Close。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=false)`

2. `SendEventByName(eventTarget={"target":2,"excludeSelf":0,"gameObject":"Owner($CameraParent)","fsmName":"CameraShake","sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="EnemyKillShake", delay=0.0, everyFrame=false)`



### Spotlight L / FSM [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1600090>)

变量初值：`{"floatVariables":{"Angle":0,"Scan Min":246.612,"Scan Max":312.431,"Start Angle":0},"boolVariables":{"Scan L":1},"gameObjectVariables":{"Target":{"fileID":2472}}}`

全局迁移：`[{"fsmEvent":{"name":"FOLLOW HERO","isSystemEvent":0,"isGlobal":0},"toState":"Follow Hero","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0},{"fsmEvent":{"name":"FOLLOW","isSystemEvent":0,"isGlobal":0},"toState":"Follow","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0},{"fsmEvent":{"name":"SCAN","isSystemEvent":0,"isGlobal":0},"toState":"Scan Dir","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0},{"fsmEvent":{"name":"TROBBIO KILLED","isSystemEvent":0,"isGlobal":0},"toState":"Follow","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0},{"fsmEvent":{"name":"END","isSystemEvent":0,"isGlobal":0},"toState":"Inert","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0}]`

#### Inert · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1600107>)

出口：无本地迁移（持续/外部驱动）。isSequence=0。



#### Follow · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1600159>)

出口：无本地迁移（持续/外部驱动）。isSequence=0。

1. `GetAngleToTarget2D(gameObject="Self", target="$Target", offsetX=0, offsetY=0, storeAngle="$Angle", pause=0, everyFrame=true)`

2. `RotateTo(gameObject="Self", targetAngle="$Angle", speed=55)`



#### Follow Hero · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1600283>)

出口：无本地迁移（持续/外部驱动）。isSequence=0。

1. `GetAngleToTarget2D(gameObject="Self", target="$Hero", offsetX=0, offsetY=0, storeAngle="$Angle", pause=0, everyFrame=true)`

2. `RotateTo(gameObject="Self", targetAngle="$Angle", speed=55)`



#### Scan Dir · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1600407>)

出口：L → Scan L；R → Scan R。isSequence=0。

1. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="FADE UP", delay=0, everyFrame=false)`

2. `BoolTest(boolVariable="$Scan L", isTrue="L", isFalse="R", everyFrame=false)`



#### Scan L · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1600541>)

出口：FINISHED → Scan R。isSequence=0。

1. `GetRotation(gameObject="Self", quaternion="None", vector="None", xAngle="None", yAngle="None", zAngle="$Start Angle", space=0, everyFrame=false)`

2. `EaseFloat(fromValue="$Start Angle", toValue="$Scan Min", floatVariable="$Angle", time=1, speed="None", delay="None", easeType=2, reverse=0, finishEvent="FINISHED", realTime=false)`

3. `SetRotation(gameObject="Self", quaternion="None", vector="None", xAngle="None", yAngle="None", zAngle="$Angle", space=0, everyFrame=true, lateUpdate=false)`



#### Scan R · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1600754>)

出口：FINISHED → Scan L。isSequence=0。

1. `GetRotation(gameObject="Self", quaternion="None", vector="None", xAngle="None", yAngle="None", zAngle="$Start Angle", space=0, everyFrame=false)`

2. `EaseFloat(fromValue="$Start Angle", toValue="$Scan Max", floatVariable="$Angle", time=1, speed="None", delay="None", easeType=2, reverse=0, finishEvent="FINISHED", realTime=false)`

3. `SetRotation(gameObject="Self", quaternion="None", vector="None", xAngle="None", yAngle="None", zAngle="$Angle", space=0, everyFrame=true, lateUpdate=false)`



### Spotlight L / Fade [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1601141>)

变量初值：`{}`

全局迁移：`[{"fsmEvent":{"name":"FADE DOWN","isSystemEvent":0,"isGlobal":0},"toState":"Down","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0}]`

#### Down · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1601158>)

出口：FADE UP → Up。isSequence=0。

1. `FadeNestedFadeGroup(Target="Self", ToAlpha=0, FadeTime=0.5)`



#### Up · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1601244>)

出口：FADE DOWN → Down。isSequence=0。

1. `FadeNestedFadeGroup(Target="Self", ToAlpha=1, FadeTime=0.5)`



### Steam Jets / Control [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1607391>)

变量初值：`{}`

全局迁移：`[]`

#### Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1607408>)

出口：PLAY → Play。isSequence=0。



#### Play · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1607469>)

出口：STOP → Idle。isSequence=0。

1. `PlayParticleEmitterChildren(gameObject="Self", resetTimeIfPlaying=false, stopOnStateExit=true)`



### Trobbio / Stun Control [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1640674>)

变量初值：`{"floatVariables":{"Combo Time":1,"Daze X Scale":0,"Daze Y Scale":0,"Hits Total":0,"Combo Counter":0,"Stun Damage":0,"Epsilon":0.01},"intVariables":{"Stun Combo":12,"Stun Hit Max":14},"boolVariables":{"Daze Effect Active":0,"Abyss Attacking":0},"gameObjectVariables":{"DazedEffect":{"fileID":0},"DazedEffect Marker":{"fileID":0},"Self":{"fileID":0}}}`

全局迁移：`[{"fsmEvent":{"name":"STUN CONTROL FORCE STUN","isSystemEvent":0,"isGlobal":0},"toState":"Stun","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0},{"fsmEvent":{"name":"STUN CONTROL STOP","isSystemEvent":0,"isGlobal":0},"toState":"Stop Daze Effect 2","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0},{"fsmEvent":{"name":"STUN CONTROL RESET","isSystemEvent":0,"isGlobal":0},"toState":"Stop Daze Effect 3","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0}]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1640691>)

出口：FINISHED → Idle。isSequence=0。

1. `GetOwner(storeGameObject="$Self")`

2. `FindChild(gameObject="Self", childName="DazedEffect Marker", storeResult="$DazedEffect Marker")`



#### Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1640786>)

出口：STUN DAMAGE → Max Check。isSequence=0。

1. `SetFloatValue(floatVariable="$Stun Damage", floatValue=0.0, everyFrame=false)`



#### In Combo · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1640852>)

出口：TIME OUT → Reset Counter；STUN DAMAGE → Continue Combo；STUN → Stun。isSequence=0。

1. `FloatAdd(floatVariable="$Combo Counter", add="$Stun Damage", everyFrame=false, perSecond=false)`

2. `FloatAdd(floatVariable="$Hits Total", add="$Stun Damage", everyFrame=false, perSecond=false)`

3. `SetFloatValue(floatVariable="$Stun Damage", floatValue=0.0, everyFrame=false)`

4. **disabled** `FloatCompare(float1="$Combo Counter", float2="$Stun Combo", tolerance="$Epsilon", equal="STUN", lessThan=null, greaterThan="STUN", everyFrame=false)`

5. `Wait(time="$Combo Time", finishEvent="TIME OUT", realTime=false)`



#### Reset Counter · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1640962>)

出口：FINISHED → Stop Daze Effect。isSequence=0。

1. `SetFloatValue(floatVariable="$Combo Counter", floatValue=0.0, everyFrame=false)`



#### Continue Combo · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1641028>)

出口：FINISHED → In Combo；STUN → Stun。isSequence=0。

1. `BoolTest(boolVariable="$Abyss Attacking", isTrue="FINISHED", isFalse=null, everyFrame=false)`

2. `FloatCompare(float1="$Hits Total", float2="$Stun Hit Max", tolerance="$Epsilon", equal="STUN", lessThan=null, greaterThan="STUN", everyFrame=false)`



#### Stun · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1641113>)

出口：FINISHED → Dazed Effect。isSequence=0。

1. `SpawnObjectFromGlobalPool(gameObject="GUID:5283cc506c688be448065d0227ce1390#1709254077376921", spawnPoint="$Self", position="None", rotation="None", storeObject="None")`

2. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="STUN", delay=0.0, everyFrame=false)`

3. `SetFloatValue(floatVariable="$Combo Counter", floatValue=0.0, everyFrame=false)`

4. `SetFloatValue(floatVariable="$Hits Total", floatValue=0.0, everyFrame=false)`

5. `SendMessage(gameObject="Self", delivery=0, options=1, functionCall={"FunctionName":"ResetSingCooldown","parameterType":"None","BoolParameter":0,"FloatParameter":0,"IntParameter":0,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`



#### Max Check · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1641390>)

出口：FINISHED → In Combo；STUN → Stun。isSequence=0。

1. `BoolTest(boolVariable="$Abyss Attacking", isTrue="FINISHED", isFalse=null, everyFrame=false)`

2. `FloatCompare(float1="$Hits Total", float2="$Stun Hit Max", tolerance="$Epsilon", equal="STUN", lessThan="FINISHED", greaterThan="STUN", everyFrame=false)`



#### Stop · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1641475>)

出口：STUN CONTROL START → Reset Counter；STUN DAMAGE → Unstun Increment。isSequence=0。



#### Unstun Increment · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1641545>)

出口：FINISHED → Stop。isSequence=0。

1. `FloatAdd(floatVariable="$Hits Total", add="$Stun Damage", everyFrame=false, perSecond=false)`

2. `SetFloatValue(floatVariable="$Stun Damage", floatValue=0.0, everyFrame=false)`



#### Reset · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1641617>)

出口：STUN CONTROL START → Reset Counter。isSequence=0。

1. `SetFloatValue(floatVariable="$Hits Total", floatValue=0.0, everyFrame=false)`



#### Dazed Effect · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1641683>)

出口：FINISHED → Stunned。isSequence=0。

1. `GameObjectIsNull(gameObject="$DazedEffect Marker", isNull="FINISHED", isNotNull=null, storeResult="None", everyFrame=false)`

2. `GetScale(gameObject="Owner($DazedEffect Marker)", vector="None", xScale="$Daze X Scale", yScale="$Daze Y Scale", zScale="None", space=0, everyFrame=false)`

3. `SpawnObjectFromGlobalPool(gameObject="GUID:da2b82da172005b4cb576be2afe73009#1709254077376921", spawnPoint="$DazedEffect Marker", position="None", rotation="None", storeObject="$DazedEffect")`

4. `SetScale(gameObject="Owner($DazedEffect)", vector="None", x="$Daze X Scale", y="$Daze Y Scale", z="None", everyFrame=false, lateUpdate=false)`

5. **disabled** `Tk2dPlayAnimation(gameObject="Owner($DazedEffect)", animLibName=null, clipName="Dazed")`

6. `SetParent(gameObject="Owner($DazedEffect)", parent="$Self", resetLocalPosition=false, resetLocalRotation=false)`



#### Stun End · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1641861>)

出口：FINISHED → Stop Daze Effect。isSequence=0。

1. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:b1c29b3804a260f4d83275f93b80ade4#8300000", pitchMin=1.0, pitchMax=1.0, volume=1.0, delay=0.0, storePlayer="fileID:0")`



#### Stunned · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1641957>)

出口：STUN CONTROL START → Stun End；TOOK HEAVY DAMAGE → Quick End。isSequence=0。



#### Quick End · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1642027>)

出口：FINISHED → Stunned；STUN CONTROL START → Stun End。isSequence=0。

1. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="END", delay=0.0, everyFrame=false)`



#### Stop Daze Effect · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1642141>)

出口：FINISHED → Idle。isSequence=0。

1. `GameObjectIsNull(gameObject="$DazedEffect", isNull="FINISHED", isNotNull=null, storeResult="None", everyFrame=false)`

2. **disabled** `Tk2dPlayAnimation(gameObject="Owner($DazedEffect)", animLibName=null, clipName="Dazed End")`

3. **disabled** `Tk2dPlayFrame(gameObject="Self", frame=0)`

4. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($DazedEffect)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="STUN EFFECT END", delay=0.0, everyFrame=false)`

5. `AudioStop(gameObject="Owner($DazedEffect)", fadeTime=0.0)`

6. `SetGameObject(variable="$DazedEffect", gameObject="fileID:0", everyFrame=false)`



#### Stop Daze Effect 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1642325>)

出口：FINISHED → Stop。isSequence=0。

1. `GameObjectIsNull(gameObject="$DazedEffect", isNull="FINISHED", isNotNull=null, storeResult="None", everyFrame=false)`

2. **disabled** `Tk2dPlayAnimation(gameObject="Owner($DazedEffect)", animLibName=null, clipName="Dazed End")`

3. **disabled** `Tk2dPlayFrame(gameObject="Self", frame=0)`

4. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($DazedEffect)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="STUN EFFECT END", delay=0.0, everyFrame=false)`

5. `AudioStop(gameObject="Owner($DazedEffect)", fadeTime=0.0)`

6. `SetGameObject(variable="$DazedEffect", gameObject="fileID:0", everyFrame=false)`



#### Stop Daze Effect 3 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1642509>)

出口：FINISHED → Reset。isSequence=0。

1. `GameObjectIsNull(gameObject="$DazedEffect", isNull="FINISHED", isNotNull=null, storeResult="None", everyFrame=false)`

2. **disabled** `Tk2dPlayAnimation(gameObject="Owner($DazedEffect)", animLibName=null, clipName="Dazed End")`

3. **disabled** `Tk2dPlayFrame(gameObject="Self", frame=0)`

4. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($DazedEffect)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="STUN EFFECT END", delay=0.0, everyFrame=false)`

5. `AudioStop(gameObject="Owner($DazedEffect)", fadeTime=0.0)`

6. `SetGameObject(variable="$DazedEffect", gameObject="fileID:0", everyFrame=false)`



### Trobbio / Control [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1648162>)

变量初值：`{"floatVariables":{"X Speed":0,"Tornado Speed":0,"Tornado Time":0,"Tornado X Min":66,"Tornado X Max":82,"Self X":0,"Floor Y":16.34,"Distance":0,"Centre X":74,"X Pos Current":0,"X Pos Target":0,"Difference":0,"Stun Timer":0,"Pitch":0,"Bomb Rotation":0,"Current Y":0,"Max Y":25.91,"Target Y":0,"Y Pos":0},"intVariables":{"Poses":0,"Extra Poses":0,"Retry":0,"Death Poses":0,"P2 HP":0},"boolVariables":{"Below P2 HP":0,"Can Evade":0,"Centred":0,"Close to Hero":0,"Doing First Attack":1,"Doing First Burst Column":0,"Enough Poses":0,"Evade Cooling Down":0,"Flare Glitter Active":0,"Force Centre":0,"Hornet Is Dead":0,"In Evade Range":0,"In Range":0,"Phase 2":0,"Timer End":0,"Wall Behind":0,"Will Burst Column":0},"stringVariables":{"Pose Anim":null},"vector3Variables":{"Throw Point Vector":{"x":0,"y":0,"z":0}},"gameObjectVariables":{"Boss Scene":{"fileID":0},"CamLock Boss":{"fileID":0},"CamLock Intro":{"fileID":0},"Confetti Shooters":{"fileID":0},"Damage Collider":{"fileID":2060},"Dazzle Flash":{"fileID":2272},"Flare Glitter":{"fileID":0},"Floor Bouncer":{"fileID":2580},"Gates":{"fileID":0},"Kill Hit":{"fileID":2341},"Projectile":{"fileID":0},"Pt Bomb Throw":{"fileID":1905},"Pt Entry Antic":{"fileID":2226},"Pt Exit":{"fileID":2806},"Pt IdleGlitter":{"fileID":2432},"Pt JumpDust":{"fileID":2295},"Pt KillHit":{"fileID":2644},"Pt Land":{"fileID":1883},"Pt SpinDust":{"fileID":2643},"Pt Stun":{"fileID":0},"Pt Tornado Dust":{"fileID":2022},"Ray Pt Centre":{"fileID":2017},"Self":{"fileID":0},"Spotlight L":{"fileID":0},"Spotlight R":{"fileID":0},"Start Range":{"fileID":0},"Steam Jets":{"fileID":0},"Throw Point":{"fileID":1609},"Tornado Damager":{"fileID":2844},"Tornado Disperse":{"fileID":0},"Trapdoor L":{"fileID":2779},"Trapdoor R":{"fileID":2893},"Pt DeathStream":{"fileID":2296},"Bind Dazzle Pickup":{"fileID":0},"Pickup Spot":{"fileID":1835},"FakeDeath Range":{"fileID":2850},"Fake Death Sprite":{"fileID":2562},"FakeDeath ExitRange":{"fileID":2579},"Smoke Loop":{"fileID":0},"Drum Loop":{"fileID":0},"Tornado Loop":{"fileID":0},"Fly Loop":{"fileID":0},"Start Range Meet":{"fileID":0},"Flinch Detector":{"fileID":1780},"Pt Intro Steam":{"fileID":0},"Dazzle Damager":{"fileID":0},"Smoke Trapdoor Loop":{"fileID":3249},"Death Fireworks Loop":{"fileID":3764},"Terrain Saver":{"fileID":3682},"Tornado Event Sender":{"fileID":3881},"Trapdoor Bursts":{"fileID":0},"Final Burst":{"fileID":0},"Audio Loop Fake Death":{"fileID":3319},"Audio Loop Voice":{"fileID":3443}}}`

全局迁移：`[{"fsmEvent":{"name":"STUN","isSystemEvent":0,"isGlobal":0},"toState":"Stun Start","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0},{"fsmEvent":{"name":"ZERO HP","isSystemEvent":0,"isGlobal":0},"toState":"Death Hit","linkStyle":0,"linkConstraint":0,"linkTarget":0,"colorIndex":0}]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1648179>)

出口：FINISHED → State。isSequence=0。

1. `GetOwner(storeGameObject="$Self")`

2. `ActivateInteractible(Target="Self", Activate=0, AllowQueueing=0, UseChildren=0)`

3. `GetParent(gameObject="Self", storeResult="$Boss Scene")`

4. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Confetti Shooters")`

5. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Smoke Loop")`

6. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Drum Loop")`

7. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Steam Jets")`

8. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Flare Glitter")`

9. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Spotlight L")`

10. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Spotlight R")`

11. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Start Range")`

12. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Start Range Meet")`

13. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Gates")`

14. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$CamLock Boss")`

15. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$CamLock Intro")`

16. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Pt Intro Steam")`

17. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Trapdoor Bursts")`

18. `FindNamedChild(gameObject="Self", storeResult="$Tornado Loop")`

19. `FindNamedChild(gameObject="Self", storeResult="$Fly Loop")`

20. `SetParent(gameObject="Owner($Trapdoor L)", parent="fileID:0", resetLocalPosition=0, resetLocalRotation=0)`

21. `SetParent(gameObject="Owner($Trapdoor R)", parent="fileID:0", resetLocalPosition=0, resetLocalRotation=0)`

22. `FindChild(gameObject="Owner($Boss Scene)", childName="Collectable Item Pickup", storeResult="$Bind Dazzle Pickup")`

23. `GetHP(target="Self", storeValue="$P2 HP")`

24. `MultiplyIntByFloat(integer="$P2 HP", multiplyFloat=0.5, storeResult="$P2 HP", everyFrame=false, forceRoundUp=false)`

25. `NextFrameEvent(sendEvent="FINISHED")`

26. `SetCollider(gameObject="Self", active=0, resetOnExit=false)`



#### Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1648742>)

出口：FINISHED → Pose Set；TOOK DAMAGE → Pose Set。isSequence=0。

1. `Wait(time=0.3, finishEvent="FINISHED", realTime=false)`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Idle")`



#### Throw Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1648849>)

出口：FINISHED → Throw。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Throw", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`

2. `SetBoolValue(boolVariable="$Doing First Attack", boolValue=0, everyFrame=false)`

3. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

4. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:6de4b2fc7cb238e4780b915dfb3a086c#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

5. `AudioPlayRandomVoiceFromTable(gameObject="Self", audioClipTable="GUID:00245b57a4ba4ec4681a896947d10a28#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`



#### Throw · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1649066>)

出口：FINISHED → Fall?。isSequence=0。

1. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:0f7482984b2251c4e8b2819d005990a3#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

2. `Tk2dWatchAnimationEvents(gameObject="Self", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `GetPosition(gameObject="Owner($Throw Point)", vector="$Throw Point Vector", x="None", y="$Current Y", z="None", space=0, everyFrame=false)`

4. `SetFloatToLowest(floatVariable="$Current Y", value1="$Current Y", value2="$Max Y", everyFrame=false)`

5. `SetVector3XYZ(vector3Variable="$Throw Point Vector", vector3Value="None", x="None", y="$Current Y", z="None", everyFrame=false)`

6. `SpawnObjectFromGlobalPool(gameObject="GUID:04bfbcef4b02e2e4b9fb18f9d0b7a165#1709254077376921", spawnPoint="None", position="$Throw Point Vector", rotation="None", storeObject="$Projectile")`

7. `RandomFloat(min=15, max=15, storeResult="$X Speed")`

8. `SetFsmFloat(gameObject="Owner($Projectile)", fsmName="Control", variableName="X Velocity", setValue="$X Speed", everyFrame=false)`

9. `SetVelocity2d(gameObject="Owner($Projectile)", vector="None", x="$X Speed", y="None", everyFrame=false)`

10. **disabled** `FloatAdd(floatVariable="$Bomb Rotation", add=90, everyFrame=false, perSecond=false)`

11. `SetFsmFloat(gameObject="Owner($Projectile)", fsmName="Control", variableName="Rotation", setValue=0, everyFrame=false)`

12. `SpawnObjectFromGlobalPool(gameObject="GUID:04bfbcef4b02e2e4b9fb18f9d0b7a165#1709254077376921", spawnPoint="None", position="$Throw Point Vector", rotation="None", storeObject="$Projectile")`

13. `RandomFloat(min=-15, max=-15, storeResult="$X Speed")`

14. `SetFsmFloat(gameObject="Owner($Projectile)", fsmName="Control", variableName="X Velocity", setValue="$X Speed", everyFrame=false)`

15. `SetVelocity2d(gameObject="Owner($Projectile)", vector="None", x="$X Speed", y="None", everyFrame=false)`

16. **disabled** `FloatAdd(floatVariable="$Bomb Rotation", add=90, everyFrame=false, perSecond=false)`

17. `SetFsmFloat(gameObject="Owner($Projectile)", fsmName="Control", variableName="Rotation", setValue=90, everyFrame=false)`

18. `SpawnObjectFromGlobalPool(gameObject="GUID:04bfbcef4b02e2e4b9fb18f9d0b7a165#1709254077376921", spawnPoint="None", position="$Throw Point Vector", rotation="None", storeObject="$Projectile")`

19. `RandomFloatEither(value1=-3, value2=3, storeResult="$X Speed")`

20. `SetFsmFloat(gameObject="Owner($Projectile)", fsmName="Control", variableName="X Velocity", setValue="$X Speed", everyFrame=false)`

21. `SetVelocity2d(gameObject="Owner($Projectile)", vector="None", x="$X Speed", y="None", everyFrame=false)`

22. **disabled** `FloatAdd(floatVariable="$Bomb Rotation", add=90, everyFrame=false, perSecond=false)`

23. `SetFsmFloat(gameObject="Owner($Projectile)", fsmName="Control", variableName="Rotation", setValue=180, everyFrame=false)`

24. `PlayParticleEmitter(gameObject="Owner($Pt Bomb Throw)", emit=0, resetIfPlaying=false)`



#### Choice · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1649854>)

出口：DAZZLE FLASH → Flash Antic；TORNADO → Tornado Antic；BOMB THROW → Throw Antic；JUMP → Jump Antic；EXIT → Exit 1；HORNET DEAD → Hornet Dead；BURST COLUMNS → Will Burst Column；TO P2 → Phase Roar Antic；SING → Sing。isSequence=0。

1. `SetIntValue(intVariable="$Extra Poses", intValue=0, everyFrame=false)`

2. **disabled** `SendEvent(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="BURST COLUMNS", delay=0, everyFrame=false)`

3. `CheckHeroPerformanceRegionV2(Target="Self", Radius=0, MinReactDelay=0, MaxReactDelay=0, None=null, ActiveInner="SING", ActiveOuter=null, IgnoreNeedolinRange=0, UseActiveBool=0, ActiveBool="None", StoreState="None", EveryFrame=false)`

4. `SendRandomEventV4(events=["TORNADO","BOMB THROW","JUMP"], weights=[1,1,1], eventMax=[1,1,1], missedMax=[5,5,4], activeBool="$Doing First Attack")`

5. `BoolTest(boolVariable="$Hornet Is Dead", isTrue="HORNET DEAD", isFalse=null, everyFrame=false)`

6. `CompareHPBool(enemy="$Self", compareTo="$P2 HP", equalBool=0, lessThanBool="$Below P2 HP", greaterThanBool=0, everyFrame=false)`

7. `BoolTestMulti(boolVariables=["$Below P2 HP","$Phase 2"], boolStates=[1,0], trueEvent="TO P2", falseEvent=null, storeResult="None", everyFrame=false)`

8. `BoolTest(boolVariable="$Doing First Burst Column", isTrue="TORNADO", isFalse=null, everyFrame=false)`

9. `SendRandomEventV4(events=["TORNADO","BOMB THROW","DAZZLE FLASH","JUMP","BURST COLUMNS"], weights=[1,1,1,1,1], eventMax=[1,1,1,1,1], missedMax=[5,5,4,4,4], activeBool="$Phase 2")`

10. `SendRandomEventV4(events=["TORNADO","BOMB THROW","DAZZLE FLASH","JUMP","EXIT"], weights=[1,1,1,1,0.75], eventMax=[1,1,1,1,1], missedMax=[5,5,4,3,4], activeBool="None")`



#### Flash Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1650579>)

出口：FINISHED → Flash Start；CANCEL → Choice。isSequence=0。

1. `GetFsmBool(gameObject="Owner($Flare Glitter)", fsmName="Control", variableName="Active", storeValue="$Flare Glitter Active", everyFrame=false)`

2. `BoolTest(boolVariable="$Flare Glitter Active", isTrue="CANCEL", isFalse=null, everyFrame=false)`

3. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

4. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Antic", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

5. **disabled** `SendEventByNameV2(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Steam Jets)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="PLAY", delay=0, everyFrame=false)`

6. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:0e0686f9ecd22fb45a43c145e0ea3893#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Flash Start · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1650863>)

出口：FINISHED → Flash Rise。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Flash Attack", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`



#### Flash Burst · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1650946>)

出口：FINISHED → Fall。isSequence=0。

1. `Tk2dWatchAnimationEvents(gameObject="Self", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `DecelerateV2(gameObject="Self", deceleration=0.825, brakeOnExit=false)`

3. `ActivateGameObject(gameObject="Owner($Dazzle Flash)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

4. `ActivateGameObject(gameObject="Owner($Dazzle Flash)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

5. **disabled** `SendEventByNameV2(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Confetti Shooters)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="PLAY", delay=0, everyFrame=false)`

6. `ScreenFlashTrobbio()`

7. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Flare Glitter)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="FLARE GLITTER", delay=0, everyFrame=false)`



#### Land · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1651197>)

出口：FINISHED → Post Dazzle Idle。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Land Quick", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `SetVelocity2d(gameObject="Self", vector={"x":0,"y":0}, x="None", y="None", everyFrame=false)`

3. `PlayParticleEmitter(gameObject="Owner($Pt Land)", emit=0, resetIfPlaying=true)`

4. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:7930b85c540bf474581e7fda7871306b#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Flash Rise · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1651391>)

出口：FINISHED → Flash Burst。isSequence=0。

1. `SetGravity2dScale(gameObject="Self", gravityScale=0)`

2. `SetVelocity2d(gameObject="Self", vector="None", x="None", y=40, everyFrame=false)`

3. `Tk2dWatchAnimationEvents(gameObject="Self", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`

4. `DecelerateV2(gameObject="Self", deceleration=0.825, brakeOnExit=false)`

5. `SendEventByNameV2(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Steam Jets)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="STOP", delay=0, everyFrame=false)`

6. `PlayParticleEmitter(gameObject="Owner($Pt JumpDust)", emit=0, resetIfPlaying=false)`

7. `AudioPlayRandomVoiceFromTable(gameObject="Self", audioClipTable="GUID:a4fd2c9fc694d844492a16e3e1f5c595#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`

8. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:9edc4820c94536845964fb16515538f7#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Fall · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1651687>)

出口：LAND → Land。isSequence=0。

1. `SetGravity2dScale(gameObject="Self", gravityScale=1)`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Fall")`

3. `CheckCollisionSide(collidingObject="Self", topHit="None", rightHit="None", bottomHit="None", leftHit="None", topHitEvent=null, rightHitEvent=null, bottomHitEvent="LAND", leftHitEvent=null, otherLayer=false, otherLayerNumber=0, ignoreTriggers=0)`

4. `CheckCollisionSideEnter(topHit="None", rightHit="None", bottomHit="None", leftHit="None", topHitEvent=null, rightHitEvent=null, bottomHitEvent="LAND", leftHitEvent=null, otherLayer=false, otherLayerNumber=0, ignoreTriggers=0)`



#### Tornado Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1651894>)

出口：FINISHED → Tornado Antic 2。isSequence=0。

1. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

2. `SetBoolValue(boolVariable="$Doing First Attack", boolValue=0, everyFrame=false)`

3. `SetBoolValue(boolVariable="$Doing First Burst Column", boolValue=0, everyFrame=false)`

4. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Antic", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

5. `DecelerateV2(gameObject="Self", deceleration=0.85, brakeOnExit=true)`

6. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:0e0686f9ecd22fb45a43c145e0ea3893#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Tornado · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1652125>)

出口：WALL → Tornado Turn；END → Tornado Slow；MULTI HIT CONNECT → Tornado Multihit。isSequence=0。

1. `AccelerateToX(gameObject="Self", accelerationFactor=0.6, targetSpeed="$Tornado Speed")`

2. `RayCast2dV2(fromGameObject="Owner($Ray Pt Centre)", fromPosition="None", direction={"x":1,"y":0}, space=1, distance=1.7, minDepth="None", maxDepth="None", hitEvent="WALL", noHitEvent=null, storeDidHit="None", storeHitObject="None", storeHitPoint="None", storeHitNormal="None", storeHitDistance="None", storeDistance="None", repeatInterval=1, layerMask=[8], invertMask=0, ignoreTriggers=0, debugColor={"r":1,"g":0.92156863,"b":0.015686275,"a":1}, debug=1)`

3. `FloatAdd(floatVariable="$Tornado Time", add=-1, everyFrame=true, perSecond=true)`

4. `FloatTestToBool(float1="$Tornado Time", float2=0, tolerance=0, equalBool="None", lessThanBool="$Timer End", greaterThanBool="None", everyFrame=true)`

5. `GetPosition(gameObject="Self", vector="None", x="$Self X", y="None", z="None", space=0, everyFrame=true)`

6. `FloatInRange(floatVariable="$Self X", lowerValue="$Tornado X Min", upperValue="$Tornado X Max", boolVariable="$In Range", trueEvent=null, falseEvent=null, everyFrame=true)`

7. `BoolAllTrue(boolVariables=["$In Range","$Timer End"], sendEvent="END", storeResult="None", everyFrame=true)`



#### Tornado Turn · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1652533>)

出口：FINISHED → Tornado。isSequence=0。

1. `GetVelocity2dNotZero(gameObject="Self", vector="None", x="$X Speed", y="None", space=0, everyFrame=false)`

2. `FloatMultiply(floatVariable="$X Speed", multiplyBy=-1, everyFrame=false)`

3. `FloatMultiply(floatVariable="$Tornado Speed", multiplyBy=-1, everyFrame=false)`

4. `SetVelocity2d(gameObject="Self", vector="None", x="$X Speed", y="None", everyFrame=false)`

5. `FlipScale(gameObject="Self", flipHorizontally=true, flipVertically=false, everyFrame=false, lateUpdate=false)`



#### Tornado Start · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1652710>)

出口：FINISHED → Tornado。isSequence=0。

1. `ActivateGameObject(gameObject="Owner($Tornado Damager)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

2. `ActivateGameObject(gameObject="Owner($Tornado Event Sender)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

3. `ActivateGameObject(gameObject="Owner($Damage Collider)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

4. `PlayParticleEmitterChildren(gameObject="Owner($Pt Tornado Dust)", resetTimeIfPlaying=true, stopOnStateExit=false)`

5. `RandomFloat(min=1.6, max=1.6, storeResult="$Tornado Time")`

6. `SetGravity2dScale(gameObject="Self", gravityScale=0.5)`

7. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Tornado")`

8. `SetFloatValue(floatVariable="$Tornado Speed", floatValue=22, everyFrame=false)`

9. `SetInvincible(target="Self", Invincible=1, InvincibleFromDirection=13, resetOnStateExit=false)`

10. `SendEventByScale(gameObject="Self", eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, xScale=true, positiveEvent="FINISHED", negativeEvent=null, space=0)`

11. `SetFloatValue(floatVariable="$Tornado Speed", floatValue=-22, everyFrame=false)`



#### Tornado End · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1653041>)

出口：FINISHED → Tornado Pose。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Tornado End", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `DecelerateXY(gameObject="Self", decelerationX=0.85, decelerationY="None", brakeOnExit=true)`

3. `SetGravity2dScale(gameObject="Self", gravityScale=1)`



#### Pose Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1653168>)

出口：FINISHED → Pose?；EVADE → Tornado Evade；TOOK DAMAGE → Evade?；TO P2 → Phase Roar Antic。isSequence=0。

1. `SelectRandomString(strings=["Pose 1","Pose 2","Pose 3"], weights=[1,1,1], storeString="$Pose Anim")`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="$Pose Anim")`

3. `Wait(time=0.5, finishEvent="FINISHED", realTime=false)`

4. `CompareHPBool(enemy="$Self", compareTo="$P2 HP", equalBool=0, lessThanBool="$Below P2 HP", greaterThanBool=0, everyFrame=false)`

5. `BoolTestMulti(boolVariables=["$Below P2 HP","$Phase 2"], boolStates=[1,0], trueEvent="TO P2", falseEvent=null, storeResult="None", everyFrame=false)`

6. `SetBoolValueAtTime(BoolVariable="$Can Evade", BoolValue=1, Time=0.25, SetOppositeOnStateEntry=true)`

7. `BoolTestMulti(boolVariables=["$Evade Cooling Down","$Can Evade","$In Evade Range"], boolStates=[0,1,1], trueEvent="EVADE", falseEvent=null, storeResult="None", everyFrame=true)`



#### Tornado Shoot · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1653516>)

出口：FINISHED → Tornado End。isSequence=0。

1. `AudioStop(gameObject="Owner($Tornado Loop)", fadeTime=0)`

2. `SetDamageHero(Target="Self", Enabled=1)`

3. `AudioPlayRandomVoiceFromTable(gameObject="Self", audioClipTable="GUID:00245b57a4ba4ec4681a896947d10a28#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`

4. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:da6ce3443f5bf8d4ebd2479c26e88434#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

5. `ActivateGameObject(gameObject="Owner($Tornado Disperse)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

6. `SpawnObjectFromGlobalPool(gameObject="GUID:0477261675dc04c408016032bc0b1626#1709254077376921", spawnPoint="$Self", position={"x":0.75,"y":-3.1,"z":-0.001}, rotation="None", storeObject="$Projectile")`

7. `SetScale(gameObject="Owner($Projectile)", vector="None", x=1, y="None", z="None", everyFrame=false, lateUpdate=false)`

8. `SpawnObjectFromGlobalPool(gameObject="GUID:0477261675dc04c408016032bc0b1626#1709254077376921", spawnPoint="$Self", position={"x":-0.75,"y":-3.1,"z":-0.001}, rotation="None", storeObject="$Projectile")`

9. `SetScale(gameObject="Owner($Projectile)", vector="None", x=-1, y="None", z="None", everyFrame=false, lateUpdate=false)`

10. `ActivateGameObject(gameObject="Owner($Tornado Damager)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

11. `ActivateGameObject(gameObject="Owner($Tornado Event Sender)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

12. `ActivateGameObject(gameObject="Owner($Damage Collider)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

13. `StopParticleEmittersInChildren(gameObject="Owner($Pt Tornado Dust)")`

14. `SetInvincible(target="Self", Invincible=0, InvincibleFromDirection=13, resetOnStateExit=false)`



#### Tornado Slow · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1653995>)

出口：FINISHED → Tornado Shoot；MULTI HIT CONNECT → Tornado Multihit。isSequence=0。

1. `DecelerateXY(gameObject="Self", decelerationX=0.9, decelerationY="None", brakeOnExit=false)`

2. `Wait(time=0.3, finishEvent="FINISHED", realTime=false)`

3. `EaseFloat(fromValue=1, toValue=0.75, floatVariable="$Pitch", time=0.3, speed="None", delay="None", easeType=21, reverse=0, finishEvent=null, realTime=false)`

4. `SetAudioPitch(gameObject="Owner($Tornado Loop)", pitch="$Pitch", everyFrame=true)`



#### Exit 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1654177>)

出口：FINISHED → Exit 2。isSequence=0。

1. `CancelRecoil(target="Self")`

2. `SetRecoilBlocked(Target="Self", IsUpBlocked=1, IsDownBlocked=0, IsLeftBlocked=0, IsRightBlocked=0)`

3. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Exit", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`

4. `AudioPlayRandomVoiceFromTable(gameObject="Self", audioClipTable="GUID:04dc803f796a4904781857565052868a#11400000", pitchOffset=0, stopPreviousSound=false, forcePlay=false)`

5. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:47d5f2aaab7426b44ad5c2e661f76f71#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Exit 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1654391>)

出口：FINISHED → Exit Pause。isSequence=0。

1. `Tk2dWatchAnimationEvents(gameObject="Self", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `SetIsKinematic2d(gameObject="Self", isKinematic=1)`

3. `SetCollider(gameObject="Self", active=0, resetOnExit=false)`

4. `PlayParticleEmitter(gameObject="Owner($Pt Exit)", emit=0, resetIfPlaying=false)`

5. `ActivateGameObject(gameObject="Owner($Damage Collider)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

6. `StopParticleEmitter(gameObject="Owner($Pt IdleGlitter)")`

7. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:0c70141410f9dbc43ae648b4b09858bc#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Pose? · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1654620>)

出口：POSE → Spin Check；FINISHED → Evade?；SING → Sing。isSequence=0。

1. `CheckHeroPerformanceRegionV2(Target="Self", Radius=0, MinReactDelay=0, MaxReactDelay=0, None=null, ActiveInner="SING", ActiveOuter=null, IgnoreNeedolinRange=0, UseActiveBool=0, ActiveBool="None", StoreState="None", EveryFrame=false)`

2. `IntAdd(intVariable="$Poses", add=-1, everyFrame=false)`

3. `IntCompare(integer1="$Poses", integer2=0, equal="FINISHED", lessThan="FINISHED", greaterThan="POSE", everyFrame=false)`

4. **disabled** `SendRandomEventV4(events=["FINISHED","POSE"], weights=[0.5,0.5], eventMax=[2,2], missedMax=[3,3], activeBool="None")`



#### Spin Check · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1654870>)

出口：CANCEL → Evade?；FORWARD → Spin F；BACK → Spin B。isSequence=0。

1. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

2. `RayCast2dV2(fromGameObject="Owner($Ray Pt Centre)", fromPosition="None", direction={"x":-1,"y":0}, space=1, distance=5, minDepth="None", maxDepth="None", hitEvent=null, noHitEvent=null, storeDidHit="$Wall Behind", storeHitObject="None", storeHitPoint="None", storeHitNormal="None", storeHitDistance="None", storeDistance="None", repeatInterval=0, layerMask=[8], invertMask=0, ignoreTriggers=0, debugColor={"r":1,"g":0.92156863,"b":0.015686275,"a":1}, debug=0)`

3. `GetXDistance(gameObject="Self", target="$Hero", storeResult="$Distance", everyFrame=false)`

4. `FloatTestToBool(float1="$Distance", float2=10, tolerance=0, equalBool="None", lessThanBool="$Close to Hero", greaterThanBool="None", everyFrame=false)`

5. `BoolTestMulti(boolVariables=["$Close to Hero","$Wall Behind"], boolStates=[1,1], trueEvent="CANCEL", falseEvent=null, storeResult="None", everyFrame=false)`

6. `BoolTestMulti(boolVariables=["$Close to Hero","$Wall Behind"], boolStates=[1,0], trueEvent="BACK", falseEvent=null, storeResult="None", everyFrame=false)`

7. `BoolTestMulti(boolVariables=["$Close to Hero","$Wall Behind"], boolStates=[0,1], trueEvent="FORWARD", falseEvent=null, storeResult="None", everyFrame=false)`

8. `SendRandomEvent(events=["FORWARD","BACK"], weights=[1,1], delay=0)`



#### Spin F · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1655362>)

出口：FINISHED → Spin。isSequence=0。

1. `SetVelocityByScale(gameObject="Self", speed=42, ySpeed="None", everyFrame=false)`



#### Spin B · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1655449>)

出口：FINISHED → Spin。isSequence=0。

1. `SetVelocityByScale(gameObject="Self", speed=-42, ySpeed="None", everyFrame=false)`



#### Spin · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1655536>)

出口：FINISHED → Pose Idle。isSequence=0。

1. `AudioPlayRandomVoiceFromTable(gameObject="Self", audioClipTable="GUID:00245b57a4ba4ec4681a896947d10a28#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`

2. `AudioPlayerOneShot(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClips=["GUID:78e5b1dbedf70944eacfdcd958d9b83f#8300000","GUID:1f9e86ed6916e964b86cbe8b16c513e4#8300000","GUID:98513f445f4b77a4f953c3cfe03146f9#8300000"], weights=[1,1,1], pitchMin=0.85, pitchMax=1.15, volume=1, delay=0, storePlayer="fileID:0")`

3. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Idle Spin", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

4. `DecelerateXY(gameObject="Self", decelerationX=0.875, decelerationY="None", brakeOnExit=true)`

5. `PlayParticleEmitter(gameObject="Owner($Pt SpinDust)", emit=0, resetIfPlaying=true)`



#### Tornado Pose · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1655768>)

出口：FINISHED → Pose Set；EVADE → Tornado Evade；TOOK DAMAGE → Tornado Evade。isSequence=0。

1. `SelectRandomString(strings=["Pose 1","Pose 2","Pose 3"], weights=[1,1,1], storeString="$Pose Anim")`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="$Pose Anim")`

3. `Wait(time=0.5, finishEvent="FINISHED", realTime=false)`

4. `AudioPlayerOneShot(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClips=["GUID:78e5b1dbedf70944eacfdcd958d9b83f#8300000","GUID:1f9e86ed6916e964b86cbe8b16c513e4#8300000","GUID:98513f445f4b77a4f953c3cfe03146f9#8300000"], weights=[1,1,1], pitchMin=0.85, pitchMax=1.15, volume=1, delay=0, storePlayer="fileID:0")`

5. `SetBoolValueAtTime(BoolVariable="$Can Evade", BoolValue=1, Time=0.35, SetOppositeOnStateEntry=false)`

6. `CheckAlertRangeByName(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, alertRangeName="Evade Tornado Range", storeResult="$In Evade Range", sendEvent=null, outOfRangeEvent=null, everyFrame=true)`

7. `BoolAllTrue(boolVariables=["$Can Evade","$In Evade Range"], sendEvent="EVADE", storeResult="None", everyFrame=true)`



#### Pose Set · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1656132>)

出口：FINISHED → Evade?。isSequence=0。

1. `RandomInt(min=1, max=2, storeResult="$Poses", inclusiveMax=true, noRepeat=0)`

2. `IntAdd(intVariable="$Poses", add="$Extra Poses", everyFrame=false)`

3. `SetIntValue(intVariable="$Extra Poses", intValue=0, everyFrame=false)`



#### Throw Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1656258>)

出口：FINISHED → Pose?。isSequence=0。

1. `Wait(time=0.5, finishEvent="FINISHED", realTime=false)`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Idle")`

3. `SetIntValue(intVariable="$Poses", intValue=3, everyFrame=false)`



#### Jump Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1656373>)

出口：FINISHED → Jump。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Jump Antic", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `SetBoolValue(boolVariable="$Doing First Attack", boolValue=0, everyFrame=false)`

3. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

4. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:0e0686f9ecd22fb45a43c145e0ea3893#8300000", pitchMin=0.85, pitchMax=1.15, volume=1, delay=0, storePlayer="fileID:0")`



#### Jump · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1656568>)

出口：FINISHED → Fly Dir。isSequence=0。

1. `SetBoolValue(boolVariable="$Will Burst Column", boolValue=0, everyFrame=false)`

2. `AudioPlayRandomVoiceFromTable(gameObject="Self", audioClipTable="GUID:00245b57a4ba4ec4681a896947d10a28#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`

3. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Jump")`

4. `SetVelocity2d(gameObject="Self", vector="None", x="None", y=30, everyFrame=false)`

5. `WaitRandom(timeMin=0.25, timeMax=0.3, finishEvent="FINISHED", realTime=false)`

6. `PlayParticleEmitter(gameObject="Owner($Pt JumpDust)", emit=0, resetIfPlaying=false)`

7. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:05014101a5989d94da43736874583fdd#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

8. `SetRecoilSpeed(target="Self", newRecoilSpeed=15)`



#### Fly Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1656841>)

出口：FINISHED → Fly。isSequence=0。

1. `SetGravity2dScale(gameObject="Self", gravityScale=0)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Fly Antic", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `DecelerateXY(gameObject="Self", decelerationX="None", decelerationY=0.85, brakeOnExit=true)`



#### Fly Dir · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1656968>)

出口：L → Fly L；R → Fly R。isSequence=0。

1. `CheckXPosition(gameObject="Self", compareTo="$Centre X", compareToOffset=0, tolerance=0, equal="R", equalBool="None", lessThan="R", lessThanBool="None", greaterThan="L", greaterThanBool="None", everyFrame=false, space=0, activeBool="None")`



#### Fly L · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1657106>)

出口：FINISHED → Jump Attack 1。isSequence=0。

1. `SetScale(gameObject="Self", vector="None", x=-1.1, y="None", z="None", everyFrame=false, lateUpdate=false)`



#### Fly R · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1657208>)

出口：FINISHED → Jump Attack 1。isSequence=0。

1. `SetScale(gameObject="Self", vector="None", x=1.1, y="None", z="None", everyFrame=false, lateUpdate=false)`



#### Fly · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1657310>)

出口：FINISHED → Jump Attack 2。isSequence=0。

1. `AudioPlaySimple(gameObject="Owner($Fly Loop)", volume=1, oneShotClip="fileID:0")`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Fly")`

3. `WaitRandom(timeMin=0.75, timeMax=1.1, finishEvent="FINISHED", realTime=false)`

4. `SetVelocityByScale(gameObject="Self", speed=15, ySpeed=-1, everyFrame=false)`

5. `RayCast2dV2(fromGameObject="Owner($Ray Pt Centre)", fromPosition="None", direction={"x":1,"y":0}, space=1, distance=6, minDepth="None", maxDepth="None", hitEvent="FINISHED", noHitEvent=null, storeDidHit="None", storeHitObject="None", storeHitPoint="None", storeHitNormal="None", storeHitDistance="None", storeDistance="None", repeatInterval=1, layerMask=[8], invertMask=0, ignoreTriggers=0, debugColor={"r":1,"g":0.92156863,"b":0.015686275,"a":1}, debug=1)`



#### Drop Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1657604>)

出口：FINISHED → Drop。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Drop Antic", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `DecelerateXY(gameObject="Self", decelerationX=0.85, decelerationY=0.85, brakeOnExit=false)`

3. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:0e0686f9ecd22fb45a43c145e0ea3893#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Drop · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1657772>)

出口：LAND → Drop Land。isSequence=0。

1. `SetGravity2dScale(gameObject="Self", gravityScale=1)`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Fall")`

3. `SetVelocity2d(gameObject="Self", vector="None", x="None", y=-10, everyFrame=false)`

4. `CheckCollisionSide(collidingObject="Self", topHit="None", rightHit="None", bottomHit="None", leftHit="None", topHitEvent=null, rightHitEvent=null, bottomHitEvent="LAND", leftHitEvent=null, otherLayer=false, otherLayerNumber=0, ignoreTriggers=0)`

5. `CheckCollisionSideEnter(topHit="None", rightHit="None", bottomHit="None", leftHit="None", topHitEvent=null, rightHitEvent=null, bottomHitEvent="LAND", leftHitEvent=null, otherLayer=false, otherLayerNumber=0, ignoreTriggers=0)`



#### Drop Land · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1658012>)

出口：FINISHED → Quick Idle。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Land", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `SetVelocity2d(gameObject="Self", vector={"x":0,"y":0}, x="None", y="None", everyFrame=false)`

3. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

4. `PlayParticleEmitter(gameObject="Owner($Pt Land)", emit=0, resetIfPlaying=true)`

5. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:7930b85c540bf474581e7fda7871306b#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Jump Attack 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1658242>)

出口：TORNADO → Tornado Antic；BOMB THROW → Air Throw Antic；FINISHED → Fly Antic。isSequence=0。

1. `SetGravity2dScale(gameObject="Self", gravityScale=0)`

2. `SendRandomEventV4(events=["FINISHED","BOMB THROW","TORNADO"], weights=[0.75,0.125,0.125], eventMax=[2,1,1], missedMax=[1,6,6], activeBool="None")`



#### Jump Attack 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1658425>)

出口：TORNADO → Tornado Antic；BOMB THROW → Air Throw Antic；FINISHED → Drop Antic；DAZZLE FLASH → Flash Start Air。isSequence=0。

1. `AudioStop(gameObject="Owner($Fly Loop)", fadeTime=0)`

2. **disabled** `SendEvent(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="DAZZLE FLASH", delay=0, everyFrame=false)`

3. `SendRandomEventV4(events=["DAZZLE FLASH","BOMB THROW","TORNADO"], weights=[0.1,0.1,0.1], eventMax=[1,1,1], missedMax=[4,3,3], activeBool="$Phase 2")`

4. `SendRandomEventV4(events=["FINISHED","BOMB THROW","TORNADO","DAZZLE FLASH"], weights=[0.75,0.125,0.125,0.2], eventMax=[1,1,1,1], missedMax=[1,5,5,5], activeBool="None")`



#### Air Throw Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1658771>)

出口：FINISHED → Throw。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Attack Throw Air", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`

2. `DecelerateV2(gameObject="Self", deceleration=0.835, brakeOnExit=false)`

3. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

4. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:6de4b2fc7cb238e4780b915dfb3a086c#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

5. `AudioPlayRandomVoiceFromTable(gameObject="Self", audioClipTable="GUID:00245b57a4ba4ec4681a896947d10a28#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`



#### Fall? · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1658990>)

出口：LAND → Throw Idle；FINISHED → Drop Antic。isSequence=0。

1. `RayCast2dV2(fromGameObject="Owner($Ray Pt Centre)", fromPosition="None", direction={"x":0,"y":-1}, space=1, distance=4, minDepth="None", maxDepth="None", hitEvent="LAND", noHitEvent=null, storeDidHit="None", storeHitObject="None", storeHitPoint="None", storeHitNormal="None", storeHitDistance="None", storeDistance="None", repeatInterval=0, layerMask=[8], invertMask=0, ignoreTriggers=0, debugColor={"r":1,"g":0.92156863,"b":0.015686275,"a":1}, debug=1)`



#### Exit Pause · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1659197>)

出口：FINISHED → Get Entry Point；BURST COLUMNS → BC Pause。isSequence=0。

1. `SetVelocity2d(gameObject="Self", vector="None", x=0, y=0, everyFrame=false)`

2. `SetMeshRenderer(gameObject="Self", active=0)`

3. `SetPosition(gameObject="Self", vector="None", x="None", y=11.3, z="None", space=0, everyFrame=false, lateUpdate=false)`

4. `Wait(time=0.3, finishEvent="FINISHED", realTime=false)`

5. `GetPosition(gameObject="Self", vector="None", x="$X Pos Current", y="None", z="None", space=0, everyFrame=false)`

6. `SetIntValue(intVariable="$Retry", intValue=0, everyFrame=false)`

7. `BoolTest(boolVariable="$Will Burst Column", isTrue="BURST COLUMNS", isFalse=null, everyFrame=false)`



#### Get Entry Point · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1659444>)

出口：RETRY → Retry；FINISHED → Bomb Flurry?。isSequence=0。

1. `RandomFloat(min=61.5, max=86.3, storeResult="$X Pos Target")`

2. `GetDifferenceBetweenFloats(differenceResult="$Difference", float1="$X Pos Current", float2="$X Pos Target", everyFrame=false)`

3. `FloatCompare(float1="$Difference", float2=10, tolerance=0, equal=null, lessThan="RETRY", greaterThan=null, everyFrame=false)`



#### Retry · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1659591>)

出口：RETRY FRAME → Retry Frame；FINISHED → Get Entry Point。isSequence=0。

1. `IntAdd(intVariable="$Retry", add=1, everyFrame=false)`

2. `IntCompare(integer1="$Retry", integer2=998, equal="RETRY FRAME", lessThan=null, greaterThan="RETRY FRAME", everyFrame=false)`



#### Retry Frame · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1659701>)

出口：FINISHED → Get Entry Point。isSequence=0。

1. `SetIntValue(intVariable="$Retry", intValue=0, everyFrame=false)`

2. `NextFrameEvent(sendEvent="FINISHED")`



#### Move Dir · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1659783>)

出口：L → Move L；R → Move R。isSequence=0。

1. `FloatCompare(float1="$X Pos Current", float2="$X Pos Target", tolerance=0, equal=null, lessThan="R", greaterThan="L", everyFrame=false)`



#### Move L · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1659883>)

出口：END → Enter Pause。isSequence=0。

1. `SetVelocity2d(gameObject="Self", vector="None", x=-19, y=0, everyFrame=false)`

2. `ActivateGameObjectDelay(gameObject="Owner($Floor Bouncer)", activate=1, resetOnExit=true, delay=0.1)`

3. `CheckXPosition(gameObject="Self", compareTo="$X Pos Target", compareToOffset=0, tolerance=0, equal="END", equalBool="None", lessThan="END", lessThanBool="None", greaterThan=null, greaterThanBool="None", everyFrame=true, space=0, activeBool="None")`



#### Move R · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1660071>)

出口：END → Enter Pause。isSequence=0。

1. `SetVelocity2d(gameObject="Self", vector="None", x=19, y=0, everyFrame=false)`

2. `ActivateGameObjectDelay(gameObject="Owner($Floor Bouncer)", activate=1, resetOnExit=true, delay=0.1)`

3. `CheckXPosition(gameObject="Self", compareTo="$X Pos Target", compareToOffset=0, tolerance=0, equal="END", equalBool="None", lessThan=null, lessThanBool="None", greaterThan="END", greaterThanBool="None", everyFrame=true, space=0, activeBool="None")`



#### Enter Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1660259>)

出口：FINISHED → Enter 1。isSequence=0。

1. `Wait(time=0.4, finishEvent="FINISHED", realTime=false)`

2. `PlayParticleEmitterInState(gameObject="Owner($Pt Entry Antic)")`

3. `AudioPlayInState(gameObject="Owner($Smoke Trapdoor Loop)", volume=1)`



#### Enter 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1660361>)

出口：FINISHED → Enter Jump?。isSequence=0。

1. `SetVelocity2d(gameObject="Self", vector="None", x=0, y=0, everyFrame=false)`

2. `SetRecoilBlocked(Target="Self", IsUpBlocked=0, IsDownBlocked=0, IsLeftBlocked=0, IsRightBlocked=0)`

3. `SetPositionToObject(gameObject="Owner($Trapdoor L)", targetObject="$Self", xOffset=-0.86, yOffset=-2.93, zOffset=-0.001, overrideZ="None", everyFrame=false)`

4. `AudioPlayRandomVoiceFromTable(gameObject="Self", audioClipTable="GUID:00245b57a4ba4ec4681a896947d10a28#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`

5. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:b9b13487d0a3f0742b19eb6b46b41878#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

6. `SetPositionToObject(gameObject="Owner($Trapdoor R)", targetObject="$Self", xOffset=1.06, yOffset=-2.93, zOffset=-0.001, overrideZ="None", everyFrame=false)`

7. `ActivateGameObject(gameObject="Owner($Trapdoor R)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

8. `ActivateGameObject(gameObject="Owner($Trapdoor L)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

9. `PlayParticleEmitter(gameObject="Owner($Pt Exit)", emit=0, resetIfPlaying=false)`

10. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

11. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Enter", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`

12. `SetInvincible(target="Self", Invincible=0, InvincibleFromDirection=0, resetOnStateExit=false)`

13. `SetMeshRenderer(gameObject="Self", active=1)`

14. `DoCameraShake(VisibleRenderer="Owner(fileID:0)", Camera="GUID:9b0888e0916dca544846a2f34304dac9#11400000", Profile="GUID:279f38013a080f34999cd00fbee1b9c2#11400000", cancelOnExit=false, DoFreeze=0, Delay=0)`

15. `SetRecoilSpeed(target="Self", newRecoilSpeed=0)`



#### Enter 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1660904>)

出口：FINISHED → Enter End。isSequence=0。

1. `Tk2dWatchAnimationEvents(gameObject="Self", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:7930b85c540bf474581e7fda7871306b#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Enter Pause · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1661039>)

出口：FINISHED → Enter Antic。isSequence=0。

1. `SetVelocity2d(gameObject="Self", vector="None", x=0, y=0, everyFrame=false)`

2. `Wait(time=0.1, finishEvent="FINISHED", realTime=false)`

3. `SetPosition(gameObject="Self", vector="None", x="$X Pos Target", y="$Floor Y", z="None", space=0, everyFrame=false, lateUpdate=false)`



#### Enter End · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1661187>)

出口：FINISHED → Pose Idle。isSequence=0。

1. `SetRecoilSpeed(target="Self", newRecoilSpeed=15)`



#### Enter Jump? · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1661266>)

出口：FINISHED → Enter 2；JUMP → Jump。isSequence=0。

1. `PlayParticleEmitter(gameObject="Owner($Pt IdleGlitter)", emit=0, resetIfPlaying=false)`

2. `SetIsKinematic2d(gameObject="Self", isKinematic=0)`

3. `SetCollider(gameObject="Self", active=1, resetOnExit=false)`

4. `ActivateGameObject(gameObject="Owner($Damage Collider)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

5. `BoolTest(boolVariable="$Will Burst Column", isTrue="JUMP", isFalse=null, everyFrame=false)`

6. `SendRandomEventV4(events=["JUMP","FINISHED"], weights=[1,1], eventMax=[2,2], missedMax=[2,2], activeBool="None")`



#### Quick Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1661496>)

出口：FINISHED → Evade?。isSequence=0。

1. `Wait(time=0.2, finishEvent="FINISHED", realTime=false)`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Idle")`



#### Rethrow? · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1661594>)

出口：FINISHED → Pose?；BOMB THROW → Throw Antic。isSequence=0。

1. `SendRandomEventV4(events=["FINISHED","BOMB THROW"], weights=[0.66,0.33], eventMax=[2,1], missedMax=[1,2], activeBool="None")`



#### Bomb Flurry? · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1661727>)

出口：FINISHED → Move Dir；BOMB THROW → Move Dir 2。isSequence=0。

1. **disabled** `SendEvent(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="BOMB THROW", delay=0, everyFrame=false)`

2. `GetDifferenceBetweenFloats(differenceResult="$Difference", float1="$X Pos Current", float2="$Centre X", everyFrame=false)`

3. `FloatCompare(float1="$Difference", float2=6, tolerance=0, equal="FINISHED", lessThan=null, greaterThan=null, everyFrame=false)`

4. `SendRandomEventV4(events=["BOMB THROW","FINISHED"], weights=[0.5,1], eventMax=[1,3], missedMax=[3,1], activeBool="None")`



#### Move Dir 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1661959>)

出口：L → Move L 2；R → Move R 2。isSequence=0。

1. `FloatCompare(float1="$X Pos Current", float2="$Centre X", tolerance=0, equal=null, lessThan="R", greaterThan="L", everyFrame=false)`



#### Move L 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1662059>)

出口：END → Flurry Pause。isSequence=0。

1. `SetVelocity2d(gameObject="Self", vector="None", x=-17, y=0, everyFrame=false)`

2. `ActivateGameObjectDelay(gameObject="Owner($Floor Bouncer)", activate=1, resetOnExit=true, delay=0.1)`

3. `CheckXPosition(gameObject="Self", compareTo="$Centre X", compareToOffset=0, tolerance=0, equal="END", equalBool="None", lessThan="END", lessThanBool="None", greaterThan=null, greaterThanBool="None", everyFrame=true, space=0, activeBool="None")`



#### Move R 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1662247>)

出口：END → Flurry Pause。isSequence=0。

1. `SetVelocity2d(gameObject="Self", vector="None", x=17, y=0, everyFrame=false)`

2. `ActivateGameObjectDelay(gameObject="Owner($Floor Bouncer)", activate=1, resetOnExit=true, delay=0.1)`

3. `CheckXPosition(gameObject="Self", compareTo="$Centre X", compareToOffset=0, tolerance=0, equal="END", equalBool="None", lessThan=null, lessThanBool="None", greaterThan="END", greaterThanBool="None", everyFrame=true, space=0, activeBool="None")`



#### Flurry Pause · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1662435>)

出口：FINISHED → Flurry Antic。isSequence=0。

1. `SetVelocity2d(gameObject="Self", vector="None", x=0, y=0, everyFrame=false)`

2. `Wait(time=0.15, finishEvent="FINISHED", realTime=false)`

3. `SetPosition(gameObject="Self", vector="None", x="$Centre X", y="$Floor Y", z="None", space=0, everyFrame=false, lateUpdate=false)`



#### Flurry Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1662583>)

出口：FINISHED → Flurry Bombs。isSequence=0。

1. `Wait(time=0.75, finishEvent="FINISHED", realTime=false)`

2. `PlayParticleEmitterInState(gameObject="Owner($Pt Entry Antic)")`

3. `AudioPlayInState(gameObject="Owner($Smoke Trapdoor Loop)", volume=1)`



#### Flurry Shot · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1662685>)

出口：FINISHED → Keep Moving。isSequence=0。

1. `SetPositionToObject(gameObject="Owner($Trapdoor L)", targetObject="$Self", xOffset=-0.86, yOffset=-2.93, zOffset=-0.001, overrideZ="None", everyFrame=false)`

2. `SetPositionToObject(gameObject="Owner($Trapdoor R)", targetObject="$Self", xOffset=1.06, yOffset=-2.93, zOffset=-0.001, overrideZ="None", everyFrame=false)`

3. `ActivateGameObject(gameObject="Owner($Trapdoor R)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

4. `ActivateGameObject(gameObject="Owner($Trapdoor L)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

5. `PlayParticleEmitter(gameObject="Owner($Pt Exit)", emit=0, resetIfPlaying=false)`

6. `DoCameraShake(VisibleRenderer="Owner(fileID:0)", Camera="GUID:9b0888e0916dca544846a2f34304dac9#11400000", Profile="GUID:279f38013a080f34999cd00fbee1b9c2#11400000", cancelOnExit=false, DoFreeze=0, Delay=0)`

7. `Wait(time=1.9, finishEvent="FINISHED", realTime=false)`



#### Keep Moving · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1662967>)

出口：FINISHED → Move Dir。isSequence=0。

1. `SetPosition(gameObject="Self", vector="None", x="None", y=11.3, z="None", space=0, everyFrame=false, lateUpdate=false)`

2. `GetPosition(gameObject="Self", vector="None", x="$X Pos Current", y="None", z="None", space=0, everyFrame=false)`

3. `RandomFloatEither(value1=-10, value2=10, storeResult="$X Pos Target")`

4. `FloatAdd(floatVariable="$X Pos Target", add="$Centre X", everyFrame=false, perSecond=false)`



#### Flurry Bombs · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1663152>)

出口：FINISHED → Flurry Shot。isSequence=0。

1. `RandomFloatEither(value1=0, value2=90, storeResult="$Bomb Rotation")`

2. `AudioPlayRandomVoiceFromTable(gameObject="Self", audioClipTable="GUID:a4fd2c9fc694d844492a16e3e1f5c595#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`

3. `SetFloatValue(floatVariable="$Target Y", floatValue="$Max Y", everyFrame=false)`

4. `GetPosition(gameObject="Owner($Throw Point)", vector="$Throw Point Vector", x="None", y="$Current Y", z="None", space=0, everyFrame=false)`

5. `FloatSubtract(floatVariable="$Target Y", subtract="$Current Y", everyFrame=false, perSecond=false)`

6. `SetFloatToLowest(floatVariable="$Target Y", value1="$Target Y", value2=0, everyFrame=false)`

7. `FloatSubtract(floatVariable="$Target Y", subtract=1, everyFrame=false, perSecond=false)`

8. `SetVector3XYZ(vector3Variable="$Throw Point Vector", vector3Value="None", x=0.5, y="$Target Y", z="None", everyFrame=false)`

9. `SpawnObjectFromGlobalPool(gameObject="GUID:04bfbcef4b02e2e4b9fb18f9d0b7a165#1709254077376921", spawnPoint="$Throw Point", position="$Throw Point Vector", rotation="None", storeObject="$Projectile")`

10. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:b9b13487d0a3f0742b19eb6b46b41878#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

11. `SetFsmFloat(gameObject="Owner($Projectile)", fsmName="Control", variableName="X Velocity", setValue=15, everyFrame=false)`

12. `SetVelocity2d(gameObject="Owner($Projectile)", vector="None", x=15, y="None", everyFrame=false)`

13. `SetFsmFloat(gameObject="Owner($Projectile)", fsmName="Control", variableName="Rotation", setValue="$Bomb Rotation", everyFrame=false)`

14. `FloatAdd(floatVariable="$Bomb Rotation", add=90, everyFrame=false, perSecond=false)`

15. `SetVector3XYZ(vector3Variable="$Throw Point Vector", vector3Value="None", x=0, y="None", z="None", everyFrame=false)`

16. `SpawnObjectFromGlobalPool(gameObject="GUID:04bfbcef4b02e2e4b9fb18f9d0b7a165#1709254077376921", spawnPoint="$Throw Point", position="$Throw Point Vector", rotation="None", storeObject="$Projectile")`

17. `SetFsmFloat(gameObject="Owner($Projectile)", fsmName="Control", variableName="X Velocity", setValue=0, everyFrame=false)`

18. `SetVelocity2d(gameObject="Owner($Projectile)", vector="None", x=0, y="None", everyFrame=false)`

19. `SetFsmFloat(gameObject="Owner($Projectile)", fsmName="Control", variableName="Rotation", setValue="$Bomb Rotation", everyFrame=false)`

20. `FloatAdd(floatVariable="$Bomb Rotation", add=90, everyFrame=false, perSecond=false)`

21. `SetVector3XYZ(vector3Variable="$Throw Point Vector", vector3Value="None", x=-0.5, y="None", z="None", everyFrame=false)`

22. `SpawnObjectFromGlobalPool(gameObject="GUID:04bfbcef4b02e2e4b9fb18f9d0b7a165#1709254077376921", spawnPoint="$Throw Point", position="$Throw Point Vector", rotation="None", storeObject="$Projectile")`

23. `SetFsmFloat(gameObject="Owner($Projectile)", fsmName="Control", variableName="X Velocity", setValue=-15, everyFrame=false)`

24. `SetVelocity2d(gameObject="Owner($Projectile)", vector="None", x=-15, y="None", everyFrame=false)`

25. `SetFsmFloat(gameObject="Owner($Projectile)", fsmName="Control", variableName="Rotation", setValue="$Bomb Rotation", everyFrame=false)`

26. `FloatAdd(floatVariable="$Bomb Rotation", add=90, everyFrame=false, perSecond=false)`



#### Stun Start · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1664011>)

出口：FINISHED → Stun Air。isSequence=0。

1. `GetPosition2d(gameObject="Self", vector_2d="None", x="None", y="$Current Y", space=0, everyFrame=false)`

2. `FloatClamp(floatVariable="$Current Y", minValue=16.91, maxValue=99999, everyFrame=false)`

3. `SetPosition2d(gameObject="Self", vector="None", x="None", y="$Current Y", space=0, everyFrame=false, lateUpdate=false)`

4. `SetBoolValue(boolVariable="$Doing First Attack", boolValue=0, everyFrame=false)`

5. `SetRecoilBlocked(Target="Self", IsUpBlocked=0, IsDownBlocked=0, IsLeftBlocked=0, IsRightBlocked=0)`

6. `SetRecoilSpeed(target="Self", newRecoilSpeed=12)`

7. `AudioPlayRandomVoiceFromTable(gameObject="Self", audioClipTable="GUID:f1b2c5e154722ad439ea2c92b9364df8#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`

8. `ScreenFlashTrobbio()`

9. `SetFloatValue(floatVariable="$Stun Timer", floatValue=2, everyFrame=false)`

10. `SetGravity2dScale(gameObject="Self", gravityScale=1)`

11. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

12. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Stun Air")`

13. `SetBoolValue(boolVariable="$Doing First Burst Column", boolValue=0, everyFrame=false)`

14. `SetVelocityByScale(gameObject="Self", speed=-6, ySpeed=20, everyFrame=false)`

15. `NextFrameEvent(sendEvent="FINISHED")`

16. `ActivateGameObject(gameObject="Owner($Tornado Damager)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

17. `ActivateGameObject(gameObject="Owner($Tornado Event Sender)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

18. `ActivateGameObject(gameObject="Owner($Damage Collider)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

19. `StopParticleEmittersInChildren(gameObject="Owner($Pt Tornado Dust)")`

20. `PlayParticleEmitter(gameObject="Owner($Pt Stun)", emit=0, resetIfPlaying=false)`

21. `AudioStop(gameObject="Owner($Tornado Loop)", fadeTime=0)`

22. `AudioStop(gameObject="Owner($Fly Loop)", fadeTime=0)`

23. `SetBoolValue(boolVariable="$Will Burst Column", boolValue=0, everyFrame=false)`

24. `SetInvincible(target="Self", Invincible=0, InvincibleFromDirection=13, resetOnStateExit=false)`

25. `SetDamageHero(Target="Self", Enabled=0)`

26. `SetMeshRenderer(gameObject="Self", active=1)`

27. `SetIsKinematic2d(gameObject="Self", isKinematic=0)`

28. `SetCollider(gameObject="Self", active=1, resetOnExit=false)`



#### Stun Air · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1664669>)

出口：LAND → Stun Land。isSequence=0。

1. `CheckCollisionSideEnter(topHit="None", rightHit="None", bottomHit="None", leftHit="None", topHitEvent=null, rightHitEvent=null, bottomHitEvent="LAND", leftHitEvent=null, otherLayer=false, otherLayerNumber=0, ignoreTriggers=0)`

2. `CheckCollisionSide(collidingObject="Self", topHit="None", rightHit="None", bottomHit="None", leftHit="None", topHitEvent=null, rightHitEvent=null, bottomHitEvent="LAND", leftHitEvent=null, otherLayer=false, otherLayerNumber=0, ignoreTriggers=0)`

3. `ActivateGameObject(gameObject="Owner(fileID:3250)", activate=1, recursive=0, resetOnExit=true, everyFrame=false)`



#### Stunned · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1664860>)

出口：END → Stun Recover；TOOK DAMAGE → Stun Damage。isSequence=0。

1. `DecelerateXY(gameObject="Self", decelerationX=0.85, decelerationY="None", brakeOnExit=false)`

2. `FloatAdd(floatVariable="$Stun Timer", add=-1, everyFrame=true, perSecond=true)`

3. `FloatCompare(float1="$Stun Timer", float2=0, tolerance=0, equal="END", lessThan="END", greaterThan=null, everyFrame=true)`

4. `AudioPlayInState(gameObject="Owner(fileID:3831)", volume=0)`

5. `FadeAudio(gameObject="Owner(fileID:3831)", startVolume=0, endVolume=1, time=0.75)`



#### Stun Recover · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1665054>)

出口：FINISHED → Quick Idle。isSequence=0。

1. `SetRecoilSpeed(target="Self", newRecoilSpeed=15)`

2. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="STUN CONTROL START", delay=0, everyFrame=false)`

3. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Stun Recover", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

4. `SetRecoilSpeed(target="Self", newRecoilSpeed=12)`

5. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:0e0686f9ecd22fb45a43c145e0ea3893#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Stun Land · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1665282>)

出口：FINISHED → Stunned。isSequence=0。

1. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Stun Land")`

2. `SetVelocity2d(gameObject="Self", vector="None", x=0, y=0, everyFrame=false)`

3. `SetDamageHero(Target="Self", Enabled=1)`

4. `PlayParticleEmitter(gameObject="Owner($Pt Land)", emit=0, resetIfPlaying=false)`

5. `ActivateGameObject(gameObject="Owner($Damage Collider)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

6. `SetRecoilSpeed(target="Self", newRecoilSpeed=5)`

7. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:7930b85c540bf474581e7fda7871306b#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Stun Damage · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1665542>)

出口：FINISHED → Stunned；END → Damage Recover。isSequence=0。

1. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

2. `AudioPlayRandomVoiceFromTable(gameObject="Self", audioClipTable="GUID:f1b2c5e154722ad439ea2c92b9364df8#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`

3. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Stun Hit")`

4. `Tk2dPlayFrame(gameObject="Self", frame=0)`

5. `FloatAdd(floatVariable="$Stun Timer", add=-0.25, everyFrame=false, perSecond=false)`

6. `FloatCompare(float1="$Stun Timer", float2=0, tolerance=0, equal="END", lessThan="END", greaterThan="FINISHED", everyFrame=false)`



#### Damage Recover · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1665761>)

出口：FINISHED → Stun Recover。isSequence=0。

1. `SendMessage(gameObject="Owner($GameManager)", delivery=0, options=1, functionCall={"FunctionName":"FreezeMoment","parameterType":"int","BoolParameter":0,"FloatParameter":0,"IntParameter":1,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`

2. `SendEventByName(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="EnemyKillShake", delay=0, everyFrame=false)`



#### Wait Refight · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1666009>)

出口：ENTER → Start Pause。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=0)`

2. `Trigger2dEvent(gameObject="Owner($Start Range)", trigger=0, collideTag=null, sendEvent="ENTER", storeCollider="None")`



#### Start Pause · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1666116>)

出口：FINISHED → Spotlight Scan；REFIGHT → Quick Entrance 1。isSequence=0。

1. `Wait(time=1, finishEvent="FINISHED", realTime=false)`

2. `SendEventToRegister(eventName="TENSION END")`

3. `ActivateGameObject(gameObject="Owner($CamLock Intro)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

4. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Gates)","fsmName":null,"sendToChildren":1,"fsmComponent":"fileID:0"}, sendEvent="BG CLOSE", delay=0, everyFrame=false)`

5. `PlayerDataBoolTest(boolName="encounteredTrobbio", isTrue="REFIGHT", isFalse=null)`



#### Spotlight Scan · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1666297>)

出口：FINISHED → Jets。isSequence=0。

1. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Spotlight L)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="SCAN", delay=0, everyFrame=false)`

2. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Spotlight R)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="SCAN", delay=0, everyFrame=false)`

3. `Wait(time=2.5, finishEvent="FINISHED", realTime=false)`

4. `AudioPlaySimple(gameObject="Owner($Drum Loop)", volume=1, oneShotClip="fileID:0")`



#### Appear Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1666496>)

出口：FINISHED → Appear 1。isSequence=0。

1. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Spotlight L)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="FOLLOW", delay=0, everyFrame=false)`

2. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Spotlight R)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="FOLLOW", delay=0, everyFrame=false)`

3. `Wait(time=1, finishEvent="FINISHED", realTime=false)`

4. `PlayParticleEmitterInState(gameObject="Owner($Pt Intro Steam)")`



#### Jets · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1666680>)

出口：FINISHED → Appear Antic。isSequence=0。

1. `PlayParticleEmitterChildren(gameObject="Owner($Steam Jets)", resetTimeIfPlaying=true, stopOnStateExit=false)`

2. `Wait(time=2, finishEvent="FINISHED", realTime=false)`

3. `AudioPlaySimple(gameObject="Owner($Smoke Loop)", volume=1, oneShotClip="fileID:0")`

4. `PlayParticleEmitterInState(gameObject="Owner($Pt Intro Steam)")`



#### Appear 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1666803>)

出口：FINISHED → Appear Rise。isSequence=0。

1. `FadeAudio(gameObject="Owner($Smoke Loop)", startVolume=1, endVolume=0, time=0.25)`

2. `SendEventToRegister(eventName="TENSION END")`

3. `FadeAudio(gameObject="Owner($Drum Loop)", startVolume=1, endVolume=0, time=0.25)`

4. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:9edc4820c94536845964fb16515538f7#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

5. `StopParticleEmittersInChildren(gameObject="Owner($Steam Jets)")`

6. `PlayParticleEmitterChildren(gameObject="Owner($Confetti Shooters)", resetTimeIfPlaying=true, stopOnStateExit=false)`

7. `SetPositionToObject(gameObject="Owner($Trapdoor L)", targetObject="$Self", xOffset=-0.86, yOffset=-2.93, zOffset=-0.001, overrideZ="None", everyFrame=false)`

8. `SetPositionToObject(gameObject="Owner($Trapdoor R)", targetObject="$Self", xOffset=1.06, yOffset=-2.93, zOffset=-0.001, overrideZ="None", everyFrame=false)`

9. `ActivateGameObject(gameObject="Owner($Trapdoor R)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

10. `ActivateGameObject(gameObject="Owner($Trapdoor L)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

11. `PlayParticleEmitter(gameObject="Owner($Pt Exit)", emit=0, resetIfPlaying=false)`

12. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

13. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Enter", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`

14. `SetMeshRenderer(gameObject="Self", active=1)`

15. `DoCameraShake(VisibleRenderer="Owner(fileID:0)", Camera="GUID:9b0888e0916dca544846a2f34304dac9#11400000", Profile="GUID:279f38013a080f34999cd00fbee1b9c2#11400000", cancelOnExit=false, DoFreeze=0, Delay=0)`



#### Appear Rise · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1667305>)

出口：FINISHED → Appear Burst。isSequence=0。

1. `AudioPlaySimple(gameObject="Self", volume=1, oneShotClip="GUID:2babf06b1ab8a6c4999ad1339f46fe2b#8300000")`

2. `PlayParticleEmitter(gameObject="Owner($Pt IdleGlitter)", emit=0, resetIfPlaying=false)`

3. `SetIsKinematic2d(gameObject="Self", isKinematic=0)`

4. `SetCollider(gameObject="Self", active=1, resetOnExit=false)`

5. `ActivateGameObject(gameObject="Owner($Damage Collider)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

6. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Flash Attack Intro", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`

7. `SetGravity2dScale(gameObject="Self", gravityScale=0)`

8. `SetVelocity2d(gameObject="Self", vector="None", x="None", y=40, everyFrame=false)`

9. `DecelerateV2(gameObject="Self", deceleration=0.825, brakeOnExit=false)`



#### Appear Burst · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1667567>)

出口：FINISHED → Fall 2。isSequence=0。

1. `Tk2dWatchAnimationEvents(gameObject="Self", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `DecelerateV2(gameObject="Self", deceleration=0.825, brakeOnExit=false)`

3. `ActivateGameObject(gameObject="Owner($Dazzle Flash)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

4. `ScreenFlashTrobbio()`

5. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Flare Glitter)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="FLARE GLITTER INTRO", delay=0, everyFrame=false)`

6. `DisplayBossTitle(areaTitleObject="$AreaTitle", displayRight=0, bossTitle="TROBBIO")`

7. `ApplyMusicCue(musicCue="GUID:eae756ca2b97202419cfcf2ea90833bb#11400000", delayTime=0, transitionTime=0)`

8. `TransitionToAudioSnapshot(snapshot="GUID:1e5b83863824c3e46b1a27345f960db5#24500036", transitionTime=0.1)`

9. `SetPlayerDataBool(boolName="encounteredTrobbio", value=1)`



#### Land 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1667821>)

出口：FINISHED → Start Idle。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Land", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `SetVelocity2d(gameObject="Self", vector={"x":0,"y":0}, x="None", y="None", everyFrame=false)`

3. `PlayParticleEmitter(gameObject="Owner($Pt Land)", emit=0, resetIfPlaying=true)`

4. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:7930b85c540bf474581e7fda7871306b#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Fall 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1668015>)

出口：LAND → Land 2。isSequence=0。

1. `SetGravity2dScale(gameObject="Self", gravityScale=1)`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Fall")`

3. `CheckCollisionSide(collidingObject="Self", topHit="None", rightHit="None", bottomHit="None", leftHit="None", topHitEvent=null, rightHitEvent=null, bottomHitEvent="LAND", leftHitEvent=null, otherLayer=false, otherLayerNumber=0, ignoreTriggers=0)`

4. `CheckCollisionSideEnter(topHit="None", rightHit="None", bottomHit="None", leftHit="None", topHitEvent=null, rightHitEvent=null, bottomHitEvent="LAND", leftHitEvent=null, otherLayer=false, otherLayerNumber=0, ignoreTriggers=0)`

5. `ActivateGameObject(gameObject="Owner($CamLock Intro)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

6. `ActivateGameObject(gameObject="Owner($CamLock Boss)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`



#### Start Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1668276>)

出口：FINISHED → Pose Set；TOOK DAMAGE → Pose Set；EVADE → Tornado Evade。isSequence=0。

1. `Wait(time=1, finishEvent="FINISHED", realTime=false)`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Idle")`

3. `PreventInvincibleEffect(target="Self", preventEffect=0)`

4. `CheckAlertRangeByName(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, alertRangeName="Evade Range", storeResult="$In Evade Range", sendEvent=null, outOfRangeEvent=null, everyFrame=true)`

5. `SetBoolValueAtTime(BoolVariable="$Can Evade", BoolValue=1, Time=0.5, SetOppositeOnStateEntry=true)`

6. `BoolAllTrue(boolVariables=["$Can Evade","$In Evade Range"], sendEvent="EVADE", storeResult="None", everyFrame=true)`



#### Death Hit · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1668521>)

出口：FINISHED → Death Fling。isSequence=0。

1. `SetIsKinematic2d(gameObject="Self", isKinematic=0)`

2. `SetCollider(gameObject="Self", active=1, resetOnExit=false)`

3. `RecordJournalKill(Record="GUID:2ca30dc46dc7c1147ac923f91c7b2efa#11400000")`

4. `SetPlayerDataBool(boolName="defeatedTrobbio", value=1)`

5. `QueueAchievement(Key="DEFEATED_TROBBIO")`

6. `PreventInvincibleEffect(target="Self", preventEffect=1)`

7. `AudioStop(gameObject="Owner($Fly Loop)", fadeTime=0)`

8. `AudioStop(gameObject="Owner($Tornado Loop)", fadeTime=0)`

9. `AudioStop(gameObject="Self", fadeTime=0)`

10. `AudioPlaySimple(gameObject="Self", volume=1, oneShotClip="GUID:0e46f04046446e340b0fbc984715fc9a#8300000")`

11. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="STUN CONTROL START", delay=0, everyFrame=false)`

12. `SetGravity2dScale(gameObject="Self", gravityScale=0)`

13. `ScreenFlashTrobbio()`

14. `SetVelocity2d(gameObject="Self", vector={"x":0,"y":0}, x="None", y="None", everyFrame=false)`

15. `StopParticleEmittersInChildren(gameObject="Owner($Pt Tornado Dust)")`

16. `PlayParticleEmitter(gameObject="Owner($Pt Stun)", emit=0, resetIfPlaying=false)`

17. `SendEventToRegister(eventName="TROBBIO KILLED")`

18. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

19. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Stun Air")`

20. `CreateObject(gameObject="GUID:be12682da8276094b8fcdc2162ff8ddd#1709254077376921", spawnPoint="$Self", position="None", rotation="None", storeObject="None")`

21. **disabled** `ActivateGameObject(gameObject="Owner($Kill Hit)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

22. `PlayParticleEmitter(gameObject="Owner($Pt KillHit)", emit=0, resetIfPlaying=false)`

23. `ApplyMusicCue(musicCue="GUID:3f1b10039c22ccd448ea6d4f450e94b1#11400000", delayTime=0, transitionTime=0)`

24. `TransitionToAudioSnapshot(snapshot="GUID:1e5b83863824c3e46b1a27345f960db5#24500034", transitionTime=0)`

25. `GetOwner(storeGameObject="$Self")`

26. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($CameraParent)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="BigShake", delay=0, everyFrame=false)`

27. **disabled** `SendMessage(gameObject="Owner($GameManager)", delivery=0, options=1, functionCall={"FunctionName":"FreezeMoment","parameterType":"int","BoolParameter":0,"FloatParameter":0,"IntParameter":2,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`

28. `PlayAudioEvent(audioClip="GUID:355ab94ffb2f4b14f8f63d140df84772#8300000", pitchMin=1, pitchMax=1, volume=1, audioPlayerPrefab="None", spawnPoint="Self", spawnPosition={"x":0,"y":0,"z":0}, SpawnedPlayerRef="None")`

29. `Wait(time=0.1, finishEvent="FINISHED", realTime=false)`

30. `ActivateGameObject(gameObject="Owner($Tornado Damager)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

31. `ActivateGameObject(gameObject="Owner($Tornado Event Sender)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

32. `ActivateGameObject(gameObject="Owner($Damage Collider)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

33. `CallMethodProper(gameObject="Self", behaviour="NonBouncer", methodName="SetActive", parameters=[{"variableName":null,"objectType":"UnityEngine.Object","useVariable":0,"type":2,"floatValue":0,"intValue":0,"boolValue":1,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}], storeResult={"variableName":null,"objectType":"UnityEngine.Object","useVariable":1,"type":-1,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}, EveryFrame=false)`

34. `SetInvincible(target="Self", Invincible=1, InvincibleFromDirection=0, resetOnStateExit=false)`

35. `SetLayer(gameObject="Self", layer=14)`

36. `GetPosition2d(gameObject="Self", vector_2d="None", x="None", y="$Y Pos", space=0, everyFrame=false)`

37. `FloatClamp(floatVariable="$Y Pos", minValue=16.7, maxValue=1000, everyFrame=false)`

38. `SetPosition2d(gameObject="Self", vector="None", x="None", y="$Y Pos", space=0, everyFrame=false, lateUpdate=false)`

39. `SetMeshRenderer(gameObject="Self", active=1)`



#### Death Fling · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1669657>)

出口：FINISHED → Death Air。isSequence=0。

1. `SetVelocityByScale(gameObject="Self", speed=-4, ySpeed=25, everyFrame=false)`

2. `SetGravity2dScale(gameObject="Self", gravityScale=1)`

3. `NextFrameEvent(sendEvent="FINISHED")`

4. `GetPosition2d(gameObject="Self", vector_2d="None", x="None", y="$Y Pos", space=0, everyFrame=false)`

5. `FloatClamp(floatVariable="$Y Pos", minValue=16.7, maxValue=1000, everyFrame=false)`

6. `SetPosition2d(gameObject="Self", vector="None", x="None", y="$Y Pos", space=0, everyFrame=false, lateUpdate=false)`



#### Death Air · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1669859>)

出口：LAND → Death Land；FINISHED → Death Catch。isSequence=0。

1. `CheckCollisionSideEnter(topHit="None", rightHit="None", bottomHit="None", leftHit="None", topHitEvent=null, rightHitEvent=null, bottomHitEvent="LAND", leftHitEvent=null, otherLayer=false, otherLayerNumber=0, ignoreTriggers=0)`

2. `CheckCollisionSide(collidingObject="Self", topHit="None", rightHit="None", bottomHit="None", leftHit="None", topHitEvent=null, rightHitEvent=null, bottomHitEvent="LAND", leftHitEvent=null, otherLayer=false, otherLayerNumber=0, ignoreTriggers=0)`

3. `GetPosition2d(gameObject="Self", vector_2d="None", x="None", y="$Y Pos", space=0, everyFrame=false)`

4. `FloatClamp(floatVariable="$Y Pos", minValue=16.7, maxValue=1000, everyFrame=false)`

5. `SetPosition2d(gameObject="Self", vector="None", x="None", y="$Y Pos", space=0, everyFrame=false, lateUpdate=false)`

6. `Wait(time=1, finishEvent="FINISHED", realTime=false)`



#### Death Land · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1670137>)

出口：L → Death Spin L；R → Death Spin R。isSequence=0。

1. `AudioPlaySimple(gameObject="Owner($Drum Loop)", volume=1, oneShotClip="fileID:0")`

2. `SetVelocity2d(gameObject="Self", vector="None", x=0, y=0, everyFrame=false)`

3. `PlayParticleEmitter(gameObject="Owner($Pt Land)", emit=0, resetIfPlaying=false)`

4. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Stun Land")`

5. **disabled** `Wait(time=0, finishEvent="FINISHED", realTime=false)`

6. `SendEventByScale(gameObject="Self", eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, xScale=true, positiveEvent="L", negativeEvent="R", space=0)`



#### Quick Entrance 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1670372>)

出口：FINISHED → Quick Entrance 2。isSequence=0。

1. `Wait(time=1, finishEvent="FINISHED", realTime=false)`



#### Quick Entrance 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1670445>)

出口：FINISHED → Quick Entrance 3。isSequence=0。

1. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Spotlight L)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="SCAN", delay=0, everyFrame=false)`

2. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Spotlight R)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="SCAN", delay=0, everyFrame=false)`

3. `PlayParticleEmitterChildren(gameObject="Owner($Steam Jets)", resetTimeIfPlaying=true, stopOnStateExit=false)`

4. `Wait(time=1.5, finishEvent="FINISHED", realTime=false)`

5. `AudioPlaySimple(gameObject="Owner($Drum Loop)", volume=1, oneShotClip="fileID:0")`

6. `AudioPlaySimple(gameObject="Owner($Smoke Loop)", volume=1, oneShotClip="fileID:0")`

7. `PlayParticleEmitterInState(gameObject="Owner($Pt Intro Steam)")`



#### Death Spin Centre · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1670694>)

出口：R → Death Spin R；L → Death Spin L。isSequence=0。

1. `CheckXPosition(gameObject="Self", compareTo="$Centre X", compareToOffset=0, tolerance=0, equal="L", equalBool="None", lessThan="R", lessThanBool="None", greaterThan="L", greaterThanBool="None", everyFrame=false, space=0, activeBool="None")`



#### Death Spin R · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1670832>)

出口：FINISHED → Death Spin。isSequence=0。

1. `SetScale(gameObject="Self", vector="None", x=1.1, y="None", z="None", everyFrame=false, lateUpdate=false)`

2. `SetVelocityByScale(gameObject="Self", speed=38, ySpeed="None", everyFrame=false)`



#### Death Spin · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1670960>)

出口：FINISHED → Force Centre?。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Idle Spin", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `DecelerateXY(gameObject="Self", decelerationX=0.875, decelerationY="None", brakeOnExit=true)`

3. `PlayParticleEmitter(gameObject="Owner($Pt SpinDust)", emit=0, resetIfPlaying=true)`

4. `AudioPlayerOneShot(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClips=["GUID:78e5b1dbedf70944eacfdcd958d9b83f#8300000","GUID:1f9e86ed6916e964b86cbe8b16c513e4#8300000","GUID:98513f445f4b77a4f953c3cfe03146f9#8300000"], weights=[1,1,1], pitchMin=0.85, pitchMax=1.15, volume=1, delay=0, storePlayer="fileID:0")`



#### Death Spin L · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1671170>)

出口：FINISHED → Death Spin。isSequence=0。

1. `SetScale(gameObject="Self", vector="None", x=-1.1, y="None", z="None", everyFrame=false, lateUpdate=false)`

2. `SetVelocityByScale(gameObject="Self", speed=38, ySpeed="None", everyFrame=false)`



#### Death Pose · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1671298>)

出口：FINISHED → Spin Type；END → Final Pose 1。isSequence=0。

1. `SelectRandomString(strings=["Death Pose 1","Death Pose 2","Death Pose 3"], weights=[1,1,1], storeString="$Pose Anim")`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="$Pose Anim")`

3. `Wait(time=1, finishEvent="FINISHED", realTime=false)`

4. `GetPosition(gameObject="Self", vector="None", x="$Self X", y="None", z="None", space=0, everyFrame=false)`

5. `FloatInRange(floatVariable="$Self X", lowerValue=72.5, upperValue=75.5, boolVariable="$Centred", trueEvent=null, falseEvent=null, everyFrame=false)`

6. `IntTestToBool(int1="$Death Poses", int2=3, equalBool="None", lessThanBool="None", greaterThanBool="$Enough Poses", everyFrame=false)`

7. `BoolAllTrue(boolVariables=["$Centred","$Enough Poses"], sendEvent="END", storeResult="None", everyFrame=false)`

8. `AudioPlayRandomVoiceFromTableV2(gameObject="Owner($Audio Loop Voice)", audioClipTable="GUID:c54ac04a7d9eddf449b1d103dcc49369#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`



#### Quick Entrance 3 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1671630>)

出口：FINISHED → Appear 1。isSequence=0。

1. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Spotlight L)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="FOLLOW", delay=0, everyFrame=false)`

2. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Spotlight R)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="FOLLOW", delay=0, everyFrame=false)`

3. `Wait(time=0.5, finishEvent="FINISHED", realTime=false)`

4. `PlayParticleEmitterInState(gameObject="Owner($Pt Intro Steam)")`



#### Death Spin Random · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1671814>)

出口：R → Death Spin R；L → Death Spin L。isSequence=0。

1. `CheckXPosition(gameObject="Self", compareTo=66.23, compareToOffset=0, tolerance=0, equal=null, equalBool="None", lessThan="R", lessThanBool="None", greaterThan=null, greaterThanBool="None", everyFrame=false, space=0, activeBool="None")`

2. `CheckXPosition(gameObject="Self", compareTo=81.11, compareToOffset=0, tolerance=0, equal=null, equalBool="None", lessThan=null, lessThanBool="None", greaterThan="L", greaterThanBool="None", everyFrame=false, space=0, activeBool="None")`

3. `SendRandomEvent(events=["L","R"], weights=[1,1], delay=0)`



#### Spin Type · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1672051>)

出口：CENTRE → Death Spin Centre；RANDOM → Death Spin Random；FORCE → Force Centre；END → Final Pose 1。isSequence=0。

1. `GetPosition(gameObject="Self", vector="None", x="$Self X", y="None", z="None", space=0, everyFrame=false)`

2. `FloatInRange(floatVariable="$Self X", lowerValue=72.5, upperValue=75.5, boolVariable="$Centred", trueEvent=null, falseEvent=null, everyFrame=false)`

3. `IntTestToBool(int1="$Death Poses", int2=3, equalBool="None", lessThanBool="None", greaterThanBool="$Enough Poses", everyFrame=false)`

4. `BoolAllTrue(boolVariables=["$Centred","$Enough Poses"], sendEvent="END", storeResult="None", everyFrame=false)`

5. `BoolTestMulti(boolVariables=["$Centred","$Enough Poses"], boolStates=[0,1], trueEvent="FORCE", falseEvent=null, storeResult="None", everyFrame=false)`

6. `IntAdd(intVariable="$Death Poses", add=1, everyFrame=false)`

7. `IntCompare(integer1="$Death Poses", integer2=2, equal="RANDOM", lessThan="RANDOM", greaterThan="CENTRE", everyFrame=false)`



#### Final Pose 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1672367>)

出口：FINISHED → Final Pose 2。isSequence=0。

1. **disabled** `SelectRandomString(strings=["Death Pose 1","Death Pose 2","Death Pose 3"], weights=[1,1,1], storeString="$Pose Anim")`

2. `AudioPlaySimple(gameObject="Owner($Death Fireworks Loop)", volume=1, oneShotClip="fileID:0")`

3. `AudioPlaySimple(gameObject="Self", volume=1, oneShotClip="GUID:be777a8a4b69a144d8ee603437c7d857#8300000")`

4. `PlayAudioEvent(audioClip="GUID:f689bd61dd9534e4586bea22f21f9c21#8300000", pitchMin=1, pitchMax=1, volume=1, audioPlayerPrefab="None", spawnPoint="Self", spawnPosition={"x":0,"y":0,"z":0}, SpawnedPlayerRef="None")`

5. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:7930b85c540bf474581e7fda7871306b#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

6. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Death Pose Final")`

7. `DoCameraShake(VisibleRenderer="Owner(fileID:0)", Camera="GUID:9b0888e0916dca544846a2f34304dac9#11400000", Profile="GUID:e483858fc9bec004c905f955c1162848#11400000", cancelOnExit=false, DoFreeze=0, Delay=0)`

8. `PlayParticleEmitter(gameObject="Owner($Pt DeathStream)", emit=0, resetIfPlaying=false)`

9. `Wait(time=1, finishEvent="FINISHED", realTime=false)`

10. `ScreenFlashTrobbio()`

11. `StopParticleEmitter(gameObject="Owner($Pt IdleGlitter)")`

12. `FindChild(gameObject="Owner($Dazzle Flash)", childName="Damager", storeResult="$Dazzle Damager")`

13. `SetDamageHero(Target="Owner($Dazzle Damager)", Enabled=0)`

14. `ActivateGameObject(gameObject="Owner($Dazzle Flash)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

15. `AudioStopV2(gameObject="Owner($Drum Loop)", fadeTime=0.5, cancelOnEarlyExit=false)`



#### Final Pose 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1672856>)

出口：FINISHED → Final Fireworks。isSequence=0。

1. `PlayParticleEmitterChildren(gameObject="Owner($Steam Jets)", resetTimeIfPlaying=true, stopOnStateExit=false)`

2. `Wait(time=1, finishEvent="FINISHED", realTime=false)`

3. `AudioPlaySimple(gameObject="Owner($Smoke Loop)", volume=1, oneShotClip="fileID:0")`



#### Final Fireworks · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1672968>)

出口：FINISHED → Stop Stream。isSequence=0。

1. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Flare Glitter)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="FINAL FLARE", delay=0, everyFrame=false)`

2. `Wait(time=2.5, finishEvent="FINISHED", realTime=false)`



#### Collapse · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1673091>)

出口：FINISHED → Battle End。isSequence=0。

1. `AwardQueuedAchievements(delay=0)`

2. `CancelCameraShake(Camera="GUID:9b0888e0916dca544846a2f34304dac9#11400000", Profile="GUID:e483858fc9bec004c905f955c1162848#11400000")`

3. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Death Collapse")`

4. `SetPositionToObject(gameObject="Owner($Bind Dazzle Pickup)", targetObject="$Pickup Spot", xOffset=0, yOffset=0, zOffset=-0.001, overrideZ="None", everyFrame=false)`

5. `ActivateGameObject(gameObject="Owner($Bind Dazzle Pickup)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

6. `Wait(time=2.5, finishEvent="FINISHED", realTime=false)`

7. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:7930b85c540bf474581e7fda7871306b#8300000", pitchMin=1, pitchMax=1, volume=0.5, delay=0, storePlayer="fileID:0")`

8. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:c8b27364625a5e8498d80e98ab1f581b#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Stop Stream · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1673408>)

出口：END → Collapse。isSequence=0。

1. `StopParticleEmitter(gameObject="Owner($Pt DeathStream)")`

2. `Wait(time=1, finishEvent="END", realTime=false)`

3. `StopParticleEmittersInChildren(gameObject="Owner($Steam Jets)")`

4. `PlayParticleEmitterChildren(gameObject="Owner($Confetti Shooters)", resetTimeIfPlaying=true, stopOnStateExit=false)`

5. `DoCameraShake(VisibleRenderer="Owner(fileID:0)", Camera="GUID:9b0888e0916dca544846a2f34304dac9#11400000", Profile="GUID:bcadf15120fe09e41b0ab53ed04fe6a4#11400000", cancelOnExit=false, DoFreeze=0, Delay=0)`

6. `AudioStopV2(gameObject="Owner($Death Fireworks Loop)", fadeTime=0, cancelOnEarlyExit=false)`

7. `AudioStopV2(gameObject="Owner($Smoke Loop)", fadeTime=0, cancelOnEarlyExit=false)`

8. `PlayAudioEvent(audioClip="GUID:47f4f8b819cf96b4bb7c0843d4fec134#8300000", pitchMin=1, pitchMax=1, volume=1, audioPlayerPrefab="None", spawnPoint="Self", spawnPosition={"x":0,"y":0,"z":0}, SpawnedPlayerRef="None")`

9. `PlayAudioEvent(audioClip="GUID:f689bd61dd9534e4586bea22f21f9c21#8300000", pitchMin=1, pitchMax=1, volume=1, audioPlayerPrefab="None", spawnPoint="Self", spawnPosition={"x":0,"y":0,"z":0}, SpawnedPlayerRef="None")`



#### Battle End · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1673720>)

出口：FINISHED → Faked Death。isSequence=0。

1. `CallMethodProper(gameObject="Self", behaviour="NonBouncer", methodName="SetActive", parameters=[{"variableName":null,"objectType":"UnityEngine.Object","useVariable":0,"type":2,"floatValue":0,"intValue":0,"boolValue":1,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}], storeResult={"variableName":null,"objectType":"UnityEngine.Object","useVariable":1,"type":-1,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}, EveryFrame=false)`

2. `ActivateGameObject(gameObject="Owner($FakeDeath Range)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

3. `ActivateGameObject(gameObject="Owner($FakeDeath ExitRange)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

4. `ActivateGameObject(gameObject="Owner($CamLock Boss)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

5. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Gates)","fsmName":null,"sendToChildren":1,"fsmComponent":"fileID:0"}, sendEvent="BG OPEN", delay=0, everyFrame=false)`



#### Force Centre · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1673990>)

出口：FINISHED → Death Spin Centre。isSequence=0。

1. `SetBoolValue(boolVariable="$Force Centre", boolValue=1, everyFrame=false)`

2. `SetBoolValueAtTime(BoolVariable="None", BoolValue=0, Time=0, SetOppositeOnStateEntry=false)`



#### Force Centre? · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1674092>)

出口：FINISHED → Death Pose。isSequence=0。

1. `BoolTest(boolVariable="$Force Centre", isTrue=null, isFalse="FINISHED", everyFrame=false)`

2. `GetPosition(gameObject="Self", vector="None", x="$Self X", y="None", z="None", space=0, everyFrame=false)`

3. `FloatClamp(floatVariable="$Self X", minValue=72.6, maxValue=75.4, everyFrame=false)`

4. `SetPosition(gameObject="Self", vector="None", x="$Self X", y="None", z="None", space=0, everyFrame=false, lateUpdate=false)`



#### Item Appear · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1674274>)

出口：FINISHED → Battle End。isSequence=1。

1. `Wait(time=0.5, finishEvent=null, realTime=false)`

2. `SetPositionToObject(gameObject="Owner($Bind Dazzle Pickup)", targetObject="$Pickup Spot", xOffset=0, yOffset=0, zOffset=-0.001, overrideZ="None", everyFrame=false)`

3. `ActivateGameObject(gameObject="Owner($Bind Dazzle Pickup)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

4. `Wait(time=1, finishEvent=null, realTime=false)`



#### Faked Death · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1674433>)

出口：EXIT → Fanning；FLINCH → Flinch。isSequence=0。

1. `CheckAlertRangeByName(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, alertRangeName="FakeDeath ExitRange", storeResult=0, sendEvent=null, outOfRangeEvent="EXIT", everyFrame=true)`

2. `Trigger2dEvent(gameObject="Owner($Flinch Detector)", trigger=0, collideTag="Nail Attack", sendEvent="FLINCH", storeCollider="None")`



#### Fanning · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1674590>)

出口：ENTER → Startle Pause。isSequence=0。

1. `ActivateGameObject(gameObject="Owner($Fake Death Sprite)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

2. `SetMeshRenderer(gameObject="Self", active=0)`

3. `CheckAlertRangeByName(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, alertRangeName="FakeDeath Range", storeResult=0, sendEvent="ENTER", outOfRangeEvent=null, everyFrame=true)`

4. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=0, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

5. `AudioPlaySimple(gameObject="Owner($Audio Loop Fake Death)", volume=1, oneShotClip="fileID:0")`

6. `ActivateGameObject(gameObject="Owner($Flinch Detector)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`



#### Startle Pause · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1674844>)

出口：FINISHED → Range Check。isSequence=0。

1. `Wait(time=0.1, finishEvent="FINISHED", realTime=false)`



#### Range Check · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1674917>)

出口：FINISHED → Startle；CANCEL → Faked Death。isSequence=0。

1. `CheckAlertRangeByName(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, alertRangeName="FakeDeath Range", storeResult=0, sendEvent=null, outOfRangeEvent="CANCEL", everyFrame=false)`



#### Startle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1675046>)

出口：FINISHED → Re-Collapse。isSequence=0。

1. `AudioStopV2(gameObject="Owner($Audio Loop Fake Death)", fadeTime=0, cancelOnEarlyExit=false)`

2. `Tk2dPlayAnimation(gameObject="Owner($Fake Death Sprite)", animLibName=null, clipName="Death Startle")`

3. `Wait(time=0.2, finishEvent="FINISHED", realTime=false)`

4. `PlayAudioEventRandom(audioClips={"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":12,"objectTypeName":"UnityEngine.AudioClip","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":["GUID:8426fe2430b7d5a479c4767dd891c173#8300000","GUID:c8a67deebb995864c9ee1886c1f44741#8300000","GUID:9041de9e6f0fb884a81835c87727a124#8300000","GUID:9ce42bdcafe4b3046a36c6821c2a3c01#8300000"]}, pitchMin=1, pitchMax=1, volume=0.6, audioPlayerPrefab="None", spawnPoint="Self", spawnPosition={"x":0,"y":0,"z":0}, SpawnedPlayerRef="None")`



#### Re-Collapse · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1675235>)

出口：FINISHED → Faked Death。isSequence=0。

1. `ActivateGameObject(gameObject="Owner($Fake Death Sprite)", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`

2. `SetMeshRenderer(gameObject="Self", active=1)`

3. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Death Collapse")`

4. `Wait(time=1, finishEvent="FINISHED", realTime=false)`

5. `Tk2dPlayFrame(gameObject="Self", frame=0)`

6. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:7930b85c540bf474581e7fda7871306b#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### State · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1675455>)

出口：MEET → Wait；REFIGHT → Wait Refight。isSequence=0。

1. `PlayerDataBoolTest(boolName="encounteredTrobbio", isTrue="REFIGHT", isFalse="MEET")`



#### Wait · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1675538>)

出口：ENTER → Take Control。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=0)`

2. `Trigger2dEvent(gameObject="Owner($Start Range Meet)", trigger=0, collideTag=null, sendEvent="ENTER", storeCollider="None")`



#### Take Control · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1675645>)

出口：LAND → Intro Jet。isSequence=0。

1. `TransitionToAudioSnapshot(snapshot="GUID:1e5b83863824c3e46b1a27345f960db5#24500034", transitionTime=3)`

2. `SetPlayerDataBool(boolName="disablePause", value=1)`

3. `RunFSM(fsmTemplateControl={"targetType":0,"target":"GUID:6acb65dd9070fec409d4a74210794792#11400000","inputVariables":[{"variable":"$Clamp X","fsmVar":{"variableName":null,"objectType":"UnityEngine.Object","useVariable":0,"type":0,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}},"isEdited":0}],"outputVariables":[],"outputEvents":[]}, finishEvent="LAND", everyFrame=false)`

4. `ActivateGameObject(gameObject="Owner($CamLock Intro)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

5. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Gates)","fsmName":null,"sendToChildren":1,"fsmComponent":"fileID:0"}, sendEvent="BG CLOSE", delay=0, everyFrame=false)`



#### Convo 1 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1675859>)

出口：CONVO_END → End Dialogue。isSequence=0。

1. **disabled** `PlayAudioEvent(audioClip="GUID:e555ae2e65da73844ba15e029835a7fc#8300000", pitchMin=1, pitchMax=1, volume=1, audioPlayerPrefab="GUID:e8466d04a5c03bc4b8d6a0838af84de7#82724804207875695", spawnPoint="Self", spawnPosition={"x":0,"y":0,"z":0}, SpawnedPlayerRef="None")`

2. `ActivateInteractible(Target="Self", Activate=1, AllowQueueing=0, UseChildren=0)`

3. `SendMessage(gameObject="Owner($Hero)", delivery=0, options=1, functionCall={"FunctionName":"StopAnimationControl","parameterType":"None","BoolParameter":0,"FloatParameter":0,"IntParameter":0,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`

4. `Tk2dPlayAnimation(gameObject="Owner($Hero)", animLibName=null, clipName="LookUp")`

5. `RunDialogue(Sheet="City", Key="TROBBIO_BOSS_MEET", OverrideContinue=0, PlayerVoiceTableOverride="fileID:0", PreventHeroAnimation=1, HideDecorators=0, TextAlignment=0, OffsetY=0, Target="Self")`



#### End Dialogue · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1676245>)

出口：FINISHED → Start Pause。isSequence=0。

1. `SendMessage(gameObject="Owner($Hero)", delivery=0, options=1, functionCall={"FunctionName":"StartAnimationControl","parameterType":"None","BoolParameter":0,"FloatParameter":0,"IntParameter":0,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`

2. `ActivateInteractible(Target="Self", Activate=0, AllowQueueing=0, UseChildren=0)`

3. `EndDialogue(ReturnControl=1, ReturnHUD=1, Target="Self", UseChildren=0)`

4. `SetPlayerDataBool(boolName="disablePause", value=0)`

5. `Wait(time=1, finishEvent="FINISHED", realTime=false)`



#### Intro Jet · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1676535>)

出口：FINISHED → Convo 1。isSequence=0。

1. `Wait(time=2, finishEvent="FINISHED", realTime=false)`

2. **disabled** `SendMessage(gameObject="Owner($Hero)", delivery=0, options=1, functionCall={"FunctionName":"StopAnimationControl","parameterType":"None","BoolParameter":0,"FloatParameter":0,"IntParameter":0,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`

3. **disabled** `Tk2dPlayAnimation(gameObject="Owner($Hero)", animLibName=null, clipName="Roar Lock")`

4. `DoCameraShake(VisibleRenderer="Owner(fileID:0)", Camera="GUID:9b0888e0916dca544846a2f34304dac9#11400000", Profile="GUID:bcadf15120fe09e41b0ab53ed04fe6a4#11400000", cancelOnExit=false, DoFreeze=1, Delay=0)`

5. **disabled** `CallMethodProper(gameObject="Owner($Hero)", behaviour="HeroController", methodName="StopAnimationControl", parameters=[], storeResult={"variableName":null,"objectType":"UnityEngine.Object","useVariable":1,"type":0,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}, EveryFrame=false)`



#### Flinch · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1676865>)

出口：FINISHED → Faked Death。isSequence=0。

1. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Death Collapse")`

2. `Tk2dPlayFrame(gameObject="Self", frame=0)`

3. `AudioPlayRandomVoiceFromTable(gameObject="Owner($Audio Loop Voice)", audioClipTable="GUID:3d006d929469a87498fe1074efe4f9a6#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`



#### Hornet Dead · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1676991>)

出口：无本地迁移（持续/外部驱动）。isSequence=0。

1. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Pose Victory")`

3. `AudioPlayRandomVoiceFromTable(gameObject="Self", audioClipTable="GUID:086ae2f2a6c4ac443944b7e51a715889#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`

4. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:0e0686f9ecd22fb45a43c145e0ea3893#8300000", pitchMin=0.85, pitchMax=1.15, volume=1, delay=0, storePlayer="fileID:0")`



#### Post Dazzle Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1677185>)

出口：FINISHED → Pose?。isSequence=0。

1. `Wait(time=0.2, finishEvent="FINISHED", realTime=false)`

2. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Idle")`

3. `SetIntValue(intVariable="$Poses", intValue=1, everyFrame=false)`



#### Tornado Multihit · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1677300>)

出口：FINISHED → Tornado Recoil。isSequence=0。

1. `SetPosition(gameObject="Self", vector="None", x="None", y="None", z=0.003, space=0, everyFrame=false, lateUpdate=false)`

2. `SetVelocity2d(gameObject="Self", vector={"x":0,"y":0}, x="None", y="None", everyFrame=false)`

3. `Wait(time=0.35, finishEvent="FINISHED", realTime=false)`



#### Tornado Recoil · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1677448>)

出口：FINISHED → Tornado Shoot。isSequence=0。

1. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

2. `SetVelocityByScale(gameObject="Self", speed=-30, ySpeed="None", everyFrame=false)`

3. `DecelerateXY(gameObject="Self", decelerationX=0.9, decelerationY="None", brakeOnExit=false)`

4. `Wait(time=0.1, finishEvent="FINISHED", realTime=false)`

5. `SetPosition(gameObject="Self", vector="None", x="None", y="None", z=0.006, space=0, everyFrame=false, lateUpdate=false)`



#### Tornado Evade · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1677651>)

出口：FINISHED → Tornado Evade Land；EXIT → Exit or Cancel。isSequence=0。

1. `SetBoolValue(boolVariable="$Evade Cooling Down", boolValue=1, everyFrame=false)`

2. `AudioPlayRandomVoiceFromTable(gameObject="Self", audioClipTable="GUID:04dc803f796a4904781857565052868a#11400000", pitchOffset=0, stopPreviousSound=false, forcePlay=false)`

3. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

4. `RayCast2dV2(fromGameObject="Owner($Ray Pt Centre)", fromPosition="None", direction={"x":-1,"y":0}, space=1, distance=6, minDepth="None", maxDepth="None", hitEvent="EXIT", noHitEvent=null, storeDidHit="None", storeHitObject="None", storeHitPoint="None", storeHitNormal="None", storeHitDistance="None", storeDistance="None", repeatInterval=0, layerMask=[8], invertMask=0, ignoreTriggers=0, debugColor={"r":1,"g":0.92156863,"b":0.015686275,"a":1}, debug=0)`

5. `SetInvincible(target="Self", Invincible=1, InvincibleFromDirection=13, resetOnStateExit=true)`

6. `SetVelocityByScale(gameObject="Self", speed=-75, ySpeed="None", everyFrame=false)`

7. `DecelerateXY(gameObject="Self", decelerationX=0.855, decelerationY="None", brakeOnExit=false)`

8. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Tornado Evade", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`

9. **disabled** `AudioPlaySimple(gameObject="Owner($Tornado Loop)", volume=1, oneShotClip="fileID:0")`

10. **disabled** `AudioPlayInState(gameObject="Owner($Tornado Loop)", volume=1)`

11. **disabled** `SetAudioPitch(gameObject="Owner($Tornado Loop)", pitch=1.75, everyFrame=false)`

12. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:adc77539bcbdf2447a275ca37b12778b#8300000", pitchMin=1.5, pitchMax=1.5, volume=1, delay=0, storePlayer="fileID:0")`

13. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:05014101a5989d94da43736874583fdd#8300000", pitchMin=1.25, pitchMax=1.25, volume=1, delay=0, storePlayer="fileID:0")`

14. `PlayParticleEmitterChildren(gameObject="Owner($Pt Tornado Dust)", resetTimeIfPlaying=true, stopOnStateExit=true)`

15. `ActivateGameObject(gameObject="Owner($Terrain Saver)", activate=1, recursive=0, resetOnExit=true, everyFrame=false)`



#### Evade? · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1678254>)

出口：FINISHED → Choice；EVADE → Tornado Evade；COOLDOWN → Reset Evade CD。isSequence=0。

1. `BoolTest(boolVariable="$Evade Cooling Down", isTrue="COOLDOWN", isFalse=null, everyFrame=false)`

2. `CheckAlertRangeByName(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, alertRangeName="Evade Range", storeResult=0, sendEvent="EVADE", outOfRangeEvent=null, everyFrame=false)`



#### Reset Evade CD · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1678406>)

出口：FINISHED → Choice。isSequence=0。

1. `SetBoolValue(boolVariable="$Evade Cooling Down", boolValue=0, everyFrame=false)`



#### Tornado Evade Land · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1678484>)

出口：FINISHED → Choice。isSequence=0。

1. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:7930b85c540bf474581e7fda7871306b#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`

2. `DecelerateXY(gameObject="Self", decelerationX=0.855, decelerationY="None", brakeOnExit=true)`

3. `Tk2dWatchAnimationEvents(gameObject="Self", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

4. `PlayParticleEmitterChildren(gameObject="Owner($Pt Tornado Dust)", resetTimeIfPlaying=true, stopOnStateExit=true)`

5. `ActivateGameObject(gameObject="Owner($Terrain Saver)", activate=1, recursive=0, resetOnExit=true, everyFrame=false)`



#### BC Pause · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1678685>)

出口：FINISHED → BC Attack。isSequence=0。

1. `Wait(time=1, finishEvent="FINISHED", realTime=false)`

2. `WaitBool(boolTest="$Phase 2", time=0.5, finishEvent="FINISHED", realTime=false)`



#### Will Burst Column · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1678777>)

出口：FINISHED → Exit 1。isSequence=0。

1. `SetBoolValue(boolVariable="$Will Burst Column", boolValue=1, everyFrame=false)`



#### BC Attack · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1678855>)

出口：FINAL BURST → Final Burst Set。isSequence=0。

1. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Trapdoor Bursts)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="ATTACK", delay=0, everyFrame=false)`



#### Final Burst Set · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1678966>)

出口：FINISHED → Final Burst。isSequence=0。

1. `GetPosition2d(gameObject="Owner($Final Burst)", vector_2d="None", x="$Self X", y="None", space=0, everyFrame=false)`

2. `SetPosition2d(gameObject="Self", vector="None", x="$Self X", y="None", space=0, everyFrame=false, lateUpdate=false)`

3. `Wait(time=0.95, finishEvent="FINISHED", realTime=false)`



#### Final Burst · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1679108>)

出口：FINISHED → Enter 1。isSequence=0。

1. `SetPosition(gameObject="Self", vector="None", x="None", y="$Floor Y", z="None", space=0, everyFrame=false, lateUpdate=false)`

2. `SetBoolValue(boolVariable="$Phase 2", boolValue=1, everyFrame=false)`

3. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:0e0686f9ecd22fb45a43c145e0ea3893#8300000", pitchMin=0.85, pitchMax=1.15, volume=1, delay=0, storePlayer="fileID:0")`



#### Phase Roar Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1679287>)

出口：FINISHED → Phase Roar。isSequence=0。

1. `SetRecoilBlocked(Target="Self", IsUpBlocked=1, IsDownBlocked=1, IsLeftBlocked=1, IsRightBlocked=1)`

2. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:1f9e86ed6916e964b86cbe8b16c513e4#8300000", pitchMin=0.85, pitchMax=1.15, volume=1, delay=0, storePlayer="fileID:0")`

3. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="STUN CONTROL STOP", delay=0, everyFrame=false)`

4. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

5. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Phase Roar", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`



#### Phase Roar · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1679554>)

出口：FINISHED → Phase Roar End。isSequence=0。

1. `StartRoarEmitter(spawnPoint="Self", delay=0, stunHero=0, roarBurst=0, isSmall=0, noVisualEffect=0, forceThroughBind=0, stopOnExit=true)`

2. `Wait(time=1.5, finishEvent="FINISHED", realTime=false)`

3. `AudioPlaySimple(gameObject="Self", volume=1, oneShotClip="GUID:e261fc334ef90624a8d2749685ee0d7e#8300000")`

4. `PlayAudioEvent(audioClip="GUID:7b31832c38310bd469ae8734210fb9f7#8300000", pitchMin=1, pitchMax=1, volume=1, audioPlayerPrefab="GUID:e8466d04a5c03bc4b8d6a0838af84de7#82724804207875695", spawnPoint="Self", spawnPosition={"x":0,"y":0,"z":0}, SpawnedPlayerRef="None")`

5. `SetBoolValue(boolVariable="$Doing First Burst Column", boolValue=1, everyFrame=false)`

6. `SetBoolValue(boolVariable="$Will Burst Column", boolValue=1, everyFrame=false)`

7. `SetBoolValue(boolVariable="$Phase 2", boolValue=1, everyFrame=false)`



#### Phase Roar End · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1679820>)

出口：FINISHED → Exit 1。isSequence=0。

1. `SetBoolValue(boolVariable="$Doing First Burst Column", boolValue=1, everyFrame=false)`

2. `SetBoolValue(boolVariable="$Will Burst Column", boolValue=1, everyFrame=false)`

3. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="STUN CONTROL START", delay=0, everyFrame=false)`

4. `SetRecoilBlocked(Target="Self", IsUpBlocked=0, IsDownBlocked=0, IsLeftBlocked=0, IsRightBlocked=0)`



#### Flash Start Air · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1680004>)

出口：FINISHED → Flash Rise Air；CANCEL → Jump Attack 2。isSequence=0。

1. `GetFsmBool(gameObject="Owner($Flare Glitter)", fsmName="Control", variableName="Active", storeValue="$Flare Glitter Active", everyFrame=false)`

2. `BoolTest(boolVariable="$Flare Glitter Active", isTrue="CANCEL", isFalse=null, everyFrame=false)`

3. `FaceObjectV2(objectA="Self", objectB="$Hero", spriteFacesRight=1, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`

4. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Flash Attack Air", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`

5. `SetGravity2dScale(gameObject="Self", gravityScale=0)`

6. `DecelerateV2(gameObject="Self", deceleration=0.875, brakeOnExit=false)`



#### Flash Rise Air · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1680216>)

出口：FINISHED → Flash Burst。isSequence=0。

1. `SetGravity2dScale(gameObject="Self", gravityScale=0)`

2. `SetVelocity2d(gameObject="Self", vector="None", x=0, y=15, everyFrame=false)`

3. `Tk2dWatchAnimationEvents(gameObject="Self", animationTriggerEvent="FINISHED", animationCompleteEvent=null)`

4. `DecelerateV2(gameObject="Self", deceleration=0.825, brakeOnExit=false)`

5. `AudioPlayRandomVoiceFromTable(gameObject="Self", audioClipTable="GUID:00245b57a4ba4ec4681a896947d10a28#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`

6. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:9edc4820c94536845964fb16515538f7#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Exit or Cancel · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1680443>)

出口：EXIT → Exit 1；CANCEL → Choice。isSequence=0。

1. `SendRandomEventV4(events=["EXIT","CANCEL"], weights=[1,1], eventMax=[1,1], missedMax=[1,1], activeBool="None")`



#### Sing · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1680576>)

出口：SING DURATION END → Sing End。isSequence=0。

1. `Tk2dPlayAnimation(gameObject="Self", animLibName=null, clipName="Sing")`

2. `EnemySingControl(enemyGameObject="Self", audioPlayer="$Audio Loop Voice", singAudioTable="GUID:daec7ecfd575804449ca88d298c77b08#11400000", noThreadEffects=1, noPuppetString=0, randomSingStartTime=0, dontStopAudioOnExit=0, altThreadSpawnPoint="fileID:0")`

3. `CheckHeroPerformanceRegionV2(Target="Self", Radius=0, MinReactDelay=0.5, MaxReactDelay=0.6, None="SING DURATION END", ActiveInner=null, ActiveOuter=null, IgnoreNeedolinRange=0, UseActiveBool=0, ActiveBool="None", StoreState="None", EveryFrame=true)`

4. `SetVelocity2d(gameObject="Self", vector="None", x=0, y="None", everyFrame=false)`

5. `AudioPlayerOneShot(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClips=["GUID:78e5b1dbedf70944eacfdcd958d9b83f#8300000","GUID:1f9e86ed6916e964b86cbe8b16c513e4#8300000","GUID:98513f445f4b77a4f953c3cfe03146f9#8300000"], weights=[1,1,1], pitchMin=0.85, pitchMax=1.15, volume=1, delay=0, storePlayer="fileID:0")`



#### Sing End · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1680906>)

出口：FINISHED → Evade?。isSequence=0。



#### Tornado Antic 2 · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1680967>)

出口：FINISHED → Tornado Start。isSequence=0。

1. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Tornado Antic", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

2. `AudioPlaySimple(gameObject="Owner($Tornado Loop)", volume=1, oneShotClip="fileID:0")`

3. `AudioPlayRandomVoiceFromTable(gameObject="Self", audioClipTable="GUID:00245b57a4ba4ec4681a896947d10a28#11400000", pitchOffset=0, stopPreviousSound=true, forcePlay=false)`

4. `SetAudioPitch(gameObject="Owner($Tornado Loop)", pitch=1, everyFrame=false)`

5. `AudioPlayerOneShotSingle(audioPlayer="GUID:99068b2a95bddff419cb6f176648d4e6#1709254077376921", spawnPoint="$Self", audioClip="GUID:adc77539bcbdf2447a275ca37b12778b#8300000", pitchMin=1, pitchMax=1, volume=1, delay=0, storePlayer="fileID:0")`



#### Death Catch · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1681176>)

出口：FINISHED → Death Land。isSequence=0。

1. `GetPosition2d(gameObject="Self", vector_2d="None", x="None", y="$Y Pos", space=0, everyFrame=false)`

2. `FloatClamp(floatVariable="$Y Pos", minValue=16.7, maxValue=1000, everyFrame=false)`

3. `SetPosition2d(gameObject="Self", vector="None", x="None", y="$Y Pos", space=0, everyFrame=false, lateUpdate=false)`



### Trobbio / Tornado Emission [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1700037>)

变量初值：`{"gameObjectVariables":{"Pt Tornado Dust":{"fileID":2022}}}`

全局迁移：`[]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1700054>)

出口：FINISHED → Floor。isSequence=0。



#### Floor · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1700115>)

出口：UP → Up。isSequence=0。

1. `CheckYPosition(gameObject="Self", compareTo=19.4, compareToOffset=0, tolerance=0, equal=null, lessThan=null, greaterThan="UP", everyFrame=true, space=0, activeBool="None")`

2. `SetPosition(gameObject="Owner($Pt Tornado Dust)", vector="None", x="None", y=0, z="None", space=1, everyFrame=false, lateUpdate=false)`



#### Up · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1700265>)

出口：DOWN → Floor。isSequence=0。

1. `CheckYPosition(gameObject="Self", compareTo=19.4, compareToOffset=0, tolerance=0, equal=null, lessThan="DOWN", greaterThan=null, everyFrame=true, space=0, activeBool="None")`

2. `SetPosition(gameObject="Owner($Pt Tornado Dust)", vector="None", x="None", y=-100, z="None", space=1, everyFrame=false, lateUpdate=false)`



### Flare Glitter 6 / Control [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1706216>)

变量初值：`{"floatVariables":{"Shift X":0,"Scale":0,"Scale Min":1,"Scale Max":1.2},"boolVariables":{"Nondamaging":0,"Do Damage":0},"gameObjectVariables":{"Pt Antic":{"fileID":2662},"Explosion":{"fileID":2994},"Damager A":{"fileID":3078},"Damager B":{"fileID":2054}}}`

全局迁移：`[]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1706233>)

出口：FINISHED → Antic。isSequence=0。

1. `RandomFloat(min=-2, max=2, storeResult="$Shift X")`

2. `SetPosition(gameObject="Owner($Explosion)", vector="None", x="$Shift X", y="None", z="None", space=1, everyFrame=false, lateUpdate=false)`

3. `SetPosition(gameObject="Owner($Pt Antic)", vector="None", x="$Shift X", y="None", z="None", space=1, everyFrame=false, lateUpdate=false)`

4. `RandomFloat(min="$Scale Min", max="$Scale Max", storeResult="$Scale")`

5. `SetScale(gameObject="Self", vector="None", x="$Scale", y="$Scale", z="None", everyFrame=false, lateUpdate=false)`



#### Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1706465>)

出口：FINISHED → Damaging?。isSequence=0。

1. `ActivateGameObject(gameObject="Owner($Pt Antic)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

2. `Wait(time=1.15, finishEvent="FINISHED", realTime=false)`

3. `PlayRandomAudioClipTable(Table="GUID:a1a3ce2d561626a4c8e732d6e5d6e1ab#11400000", AudioPlayerPrefab="None", SpawnPoint="Self", SpawnPosition={"x":0,"y":0,"z":0})`



#### Explode · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1706599>)

出口：FINISHED → End。isSequence=0。

1. `Wait(time=1, finishEvent="FINISHED", realTime=false)`

2. `ActivateGameObject(gameObject="Owner($Explosion)", activate=1, recursive=0, resetOnExit=true, everyFrame=false)`

3. `SetRandomRotation(gameObject="Owner($Explosion)", x=0, y=0, z=1)`

4. `PlayRandomAudioClipTable(Table="GUID:983b3b99e4f475f45b0a27cbeda95088#11400000", AudioPlayerPrefab="None", SpawnPoint="Self", SpawnPosition={"x":0,"y":0,"z":0})`



#### End · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1706765>)

出口：无本地迁移（持续/外部驱动）。isSequence=0。

1. `ActivateGameObject(gameObject="Self", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`



#### Damaging? · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1706844>)

出口：FINISHED → Explode。isSequence=0。

1. `SetBoolValue(boolVariable="$Do Damage", boolValue="$Nondamaging", everyFrame=false)`

2. `BoolFlip(boolVariable="$Do Damage")`

3. `SetDamageHero(Target="Owner($Damager A)", Enabled="$Do Damage")`

4. `SetDamageHero(Target="Owner($Damager B)", Enabled="$Do Damage")`



### Flare Glitter 4 / Control [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1708865>)

变量初值：`{"floatVariables":{"Shift X":0,"Scale":0,"Scale Min":1,"Scale Max":1.2},"boolVariables":{"Nondamaging":0,"Do Damage":0},"gameObjectVariables":{"Pt Antic":{"fileID":2660},"Explosion":{"fileID":2990},"Damager A":{"fileID":3073},"Damager B":{"fileID":2051}}}`

全局迁移：`[]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1708882>)

出口：FINISHED → Antic。isSequence=0。

1. `RandomFloat(min=-2, max=2, storeResult="$Shift X")`

2. `SetPosition(gameObject="Owner($Explosion)", vector="None", x="$Shift X", y="None", z="None", space=1, everyFrame=false, lateUpdate=false)`

3. `SetPosition(gameObject="Owner($Pt Antic)", vector="None", x="$Shift X", y="None", z="None", space=1, everyFrame=false, lateUpdate=false)`

4. `RandomFloat(min="$Scale Min", max="$Scale Max", storeResult="$Scale")`

5. `SetScale(gameObject="Self", vector="None", x="$Scale", y="$Scale", z="None", everyFrame=false, lateUpdate=false)`



#### Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1709114>)

出口：FINISHED → Damaging?。isSequence=0。

1. `ActivateGameObject(gameObject="Owner($Pt Antic)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

2. `Wait(time=1.15, finishEvent="FINISHED", realTime=false)`

3. `PlayRandomAudioClipTable(Table="GUID:a1a3ce2d561626a4c8e732d6e5d6e1ab#11400000", AudioPlayerPrefab="None", SpawnPoint="Self", SpawnPosition={"x":0,"y":0,"z":0})`



#### Explode · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1709248>)

出口：FINISHED → End。isSequence=0。

1. `Wait(time=1, finishEvent="FINISHED", realTime=false)`

2. `ActivateGameObject(gameObject="Owner($Explosion)", activate=1, recursive=0, resetOnExit=true, everyFrame=false)`

3. `SetRandomRotation(gameObject="Owner($Explosion)", x=0, y=0, z=1)`

4. `PlayRandomAudioClipTable(Table="GUID:983b3b99e4f475f45b0a27cbeda95088#11400000", AudioPlayerPrefab="None", SpawnPoint="Self", SpawnPosition={"x":0,"y":0,"z":0})`



#### End · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1709414>)

出口：无本地迁移（持续/外部驱动）。isSequence=0。

1. `ActivateGameObject(gameObject="Self", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`



#### Damaging? · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1709493>)

出口：FINISHED → Explode。isSequence=0。

1. `SetBoolValue(boolVariable="$Do Damage", boolValue="$Nondamaging", everyFrame=false)`

2. `BoolFlip(boolVariable="$Do Damage")`

3. `SetDamageHero(Target="Owner($Damager A)", Enabled="$Do Damage")`

4. `SetDamageHero(Target="Owner($Damager B)", Enabled="$Do Damage")`



### Flare Glitter 1 / Control [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1710631>)

变量初值：`{"floatVariables":{"Shift X":0,"Scale":0,"Scale Min":1,"Scale Max":1.2},"boolVariables":{"Nondamaging":0,"Do Damage":0},"gameObjectVariables":{"Pt Antic":{"fileID":2657},"Explosion":{"fileID":2992},"Damager A":{"fileID":3076},"Damager B":{"fileID":2052}}}`

全局迁移：`[]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1710648>)

出口：FINISHED → Antic。isSequence=0。

1. `RandomFloat(min=-2, max=2, storeResult="$Shift X")`

2. `SetPosition(gameObject="Owner($Explosion)", vector="None", x="$Shift X", y="None", z="None", space=1, everyFrame=false, lateUpdate=false)`

3. `SetPosition(gameObject="Owner($Pt Antic)", vector="None", x="$Shift X", y="None", z="None", space=1, everyFrame=false, lateUpdate=false)`

4. `RandomFloat(min="$Scale Min", max="$Scale Max", storeResult="$Scale")`

5. `SetScale(gameObject="Self", vector="None", x="$Scale", y="$Scale", z="None", everyFrame=false, lateUpdate=false)`



#### Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1710880>)

出口：FINISHED → Damaging?。isSequence=0。

1. `ActivateGameObject(gameObject="Owner($Pt Antic)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

2. `Wait(time=1.15, finishEvent="FINISHED", realTime=false)`

3. `PlayRandomAudioClipTable(Table="GUID:a1a3ce2d561626a4c8e732d6e5d6e1ab#11400000", AudioPlayerPrefab="None", SpawnPoint="Self", SpawnPosition={"x":0,"y":0,"z":0})`



#### Explode · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1711014>)

出口：FINISHED → End。isSequence=0。

1. `Wait(time=1, finishEvent="FINISHED", realTime=false)`

2. `ActivateGameObject(gameObject="Owner($Explosion)", activate=1, recursive=0, resetOnExit=true, everyFrame=false)`

3. `SetRandomRotation(gameObject="Owner($Explosion)", x=0, y=0, z=1)`

4. `PlayRandomAudioClipTable(Table="GUID:983b3b99e4f475f45b0a27cbeda95088#11400000", AudioPlayerPrefab="None", SpawnPoint="Self", SpawnPosition={"x":0,"y":0,"z":0})`



#### End · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1711180>)

出口：无本地迁移（持续/外部驱动）。isSequence=0。

1. `ActivateGameObject(gameObject="Self", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`



#### Damaging? · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1711259>)

出口：FINISHED → Explode。isSequence=0。

1. `SetBoolValue(boolVariable="$Do Damage", boolValue="$Nondamaging", everyFrame=false)`

2. `BoolFlip(boolVariable="$Do Damage")`

3. `SetDamageHero(Target="Owner($Damager A)", Enabled="$Do Damage")`

4. `SetDamageHero(Target="Owner($Damager B)", Enabled="$Do Damage")`



### Flare Glitter 2 / Control [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1712397>)

变量初值：`{"floatVariables":{"Shift X":0,"Scale":0,"Scale Min":1,"Scale Max":1.2},"boolVariables":{"Nondamaging":0,"Do Damage":0},"gameObjectVariables":{"Pt Antic":{"fileID":2672},"Explosion":{"fileID":3000},"Damager A":{"fileID":3084},"Damager B":{"fileID":2043}}}`

全局迁移：`[]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1712414>)

出口：FINISHED → Antic。isSequence=0。

1. `RandomFloat(min=-2, max=2, storeResult="$Shift X")`

2. `SetPosition(gameObject="Owner($Explosion)", vector="None", x="$Shift X", y="None", z="None", space=1, everyFrame=false, lateUpdate=false)`

3. `SetPosition(gameObject="Owner($Pt Antic)", vector="None", x="$Shift X", y="None", z="None", space=1, everyFrame=false, lateUpdate=false)`

4. `RandomFloat(min="$Scale Min", max="$Scale Max", storeResult="$Scale")`

5. `SetScale(gameObject="Self", vector="None", x="$Scale", y="$Scale", z="None", everyFrame=false, lateUpdate=false)`



#### Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1712646>)

出口：FINISHED → Damaging?。isSequence=0。

1. `ActivateGameObject(gameObject="Owner($Pt Antic)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

2. `Wait(time=1.15, finishEvent="FINISHED", realTime=false)`

3. `PlayRandomAudioClipTable(Table="GUID:a1a3ce2d561626a4c8e732d6e5d6e1ab#11400000", AudioPlayerPrefab="None", SpawnPoint="Self", SpawnPosition={"x":0,"y":0,"z":0})`



#### Explode · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1712780>)

出口：FINISHED → End。isSequence=0。

1. `Wait(time=1, finishEvent="FINISHED", realTime=false)`

2. `ActivateGameObject(gameObject="Owner($Explosion)", activate=1, recursive=0, resetOnExit=true, everyFrame=false)`

3. `SetRandomRotation(gameObject="Owner($Explosion)", x=0, y=0, z=1)`

4. `PlayRandomAudioClipTable(Table="GUID:983b3b99e4f475f45b0a27cbeda95088#11400000", AudioPlayerPrefab="None", SpawnPoint="Self", SpawnPosition={"x":0,"y":0,"z":0})`



#### End · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1712946>)

出口：无本地迁移（持续/外部驱动）。isSequence=0。

1. `ActivateGameObject(gameObject="Self", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`



#### Damaging? · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1713025>)

出口：FINISHED → Explode。isSequence=0。

1. `SetBoolValue(boolVariable="$Do Damage", boolValue="$Nondamaging", everyFrame=false)`

2. `BoolFlip(boolVariable="$Do Damage")`

3. `SetDamageHero(Target="Owner($Damager A)", Enabled="$Do Damage")`

4. `SetDamageHero(Target="Owner($Damager B)", Enabled="$Do Damage")`



### Flare Glitter 5 / Control [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1714163>)

变量初值：`{"floatVariables":{"Shift X":0,"Scale":0,"Scale Min":1,"Scale Max":1.2},"boolVariables":{"Nondamaging":0,"Do Damage":0},"gameObjectVariables":{"Pt Antic":{"fileID":2671},"Explosion":{"fileID":3002},"Damager A":{"fileID":3085},"Damager B":{"fileID":2044}}}`

全局迁移：`[]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1714180>)

出口：FINISHED → Antic。isSequence=0。

1. `RandomFloat(min=-2, max=2, storeResult="$Shift X")`

2. `SetPosition(gameObject="Owner($Explosion)", vector="None", x="$Shift X", y="None", z="None", space=1, everyFrame=false, lateUpdate=false)`

3. `SetPosition(gameObject="Owner($Pt Antic)", vector="None", x="$Shift X", y="None", z="None", space=1, everyFrame=false, lateUpdate=false)`

4. `RandomFloat(min="$Scale Min", max="$Scale Max", storeResult="$Scale")`

5. `SetScale(gameObject="Self", vector="None", x="$Scale", y="$Scale", z="None", everyFrame=false, lateUpdate=false)`



#### Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1714412>)

出口：FINISHED → Damaging?。isSequence=0。

1. `ActivateGameObject(gameObject="Owner($Pt Antic)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

2. `Wait(time=1.15, finishEvent="FINISHED", realTime=false)`

3. `PlayRandomAudioClipTable(Table="GUID:a1a3ce2d561626a4c8e732d6e5d6e1ab#11400000", AudioPlayerPrefab="None", SpawnPoint="Self", SpawnPosition={"x":0,"y":0,"z":0})`



#### Explode · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1714546>)

出口：FINISHED → End。isSequence=0。

1. `Wait(time=1, finishEvent="FINISHED", realTime=false)`

2. `ActivateGameObject(gameObject="Owner($Explosion)", activate=1, recursive=0, resetOnExit=true, everyFrame=false)`

3. `SetRandomRotation(gameObject="Owner($Explosion)", x=0, y=0, z=1)`

4. `PlayRandomAudioClipTable(Table="GUID:983b3b99e4f475f45b0a27cbeda95088#11400000", AudioPlayerPrefab="None", SpawnPoint="Self", SpawnPosition={"x":0,"y":0,"z":0})`



#### End · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1714712>)

出口：无本地迁移（持续/外部驱动）。isSequence=0。

1. `ActivateGameObject(gameObject="Self", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`



#### Damaging? · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1714791>)

出口：FINISHED → Explode。isSequence=0。

1. `SetBoolValue(boolVariable="$Do Damage", boolValue="$Nondamaging", everyFrame=false)`

2. `BoolFlip(boolVariable="$Do Damage")`

3. `SetDamageHero(Target="Owner($Damager A)", Enabled="$Do Damage")`

4. `SetDamageHero(Target="Owner($Damager B)", Enabled="$Do Damage")`



### Flare Glitter 3 / Control [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1719461>)

变量初值：`{"floatVariables":{"Shift X":0,"Scale":0,"Scale Min":1,"Scale Max":1.2},"boolVariables":{"Nondamaging":0,"Do Damage":0},"gameObjectVariables":{"Pt Antic":{"fileID":2664},"Explosion":{"fileID":2998},"Damager A":{"fileID":3082},"Damager B":{"fileID":2041}}}`

全局迁移：`[]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1719478>)

出口：FINISHED → Antic。isSequence=0。

1. `RandomFloat(min=-2, max=2, storeResult="$Shift X")`

2. `SetPosition(gameObject="Owner($Explosion)", vector="None", x="$Shift X", y="None", z="None", space=1, everyFrame=false, lateUpdate=false)`

3. `SetPosition(gameObject="Owner($Pt Antic)", vector="None", x="$Shift X", y="None", z="None", space=1, everyFrame=false, lateUpdate=false)`

4. `RandomFloat(min="$Scale Min", max="$Scale Max", storeResult="$Scale")`

5. `SetScale(gameObject="Self", vector="None", x="$Scale", y="$Scale", z="None", everyFrame=false, lateUpdate=false)`



#### Antic · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1719710>)

出口：FINISHED → Damaging?。isSequence=0。

1. `ActivateGameObject(gameObject="Owner($Pt Antic)", activate=1, recursive=0, resetOnExit=false, everyFrame=false)`

2. `Wait(time=1.15, finishEvent="FINISHED", realTime=false)`

3. `PlayRandomAudioClipTable(Table="GUID:a1a3ce2d561626a4c8e732d6e5d6e1ab#11400000", AudioPlayerPrefab="None", SpawnPoint="Self", SpawnPosition={"x":0,"y":0,"z":0})`



#### Explode · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1719844>)

出口：FINISHED → End。isSequence=0。

1. `Wait(time=1, finishEvent="FINISHED", realTime=false)`

2. `ActivateGameObject(gameObject="Owner($Explosion)", activate=1, recursive=0, resetOnExit=true, everyFrame=false)`

3. `SetRandomRotation(gameObject="Owner($Explosion)", x=0, y=0, z=1)`

4. `PlayRandomAudioClipTable(Table="GUID:983b3b99e4f475f45b0a27cbeda95088#11400000", AudioPlayerPrefab="None", SpawnPoint="Self", SpawnPosition={"x":0,"y":0,"z":0})`



#### End · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1720010>)

出口：无本地迁移（持续/外部驱动）。isSequence=0。

1. `ActivateGameObject(gameObject="Self", activate=0, recursive=0, resetOnExit=false, everyFrame=false)`



#### Damaging? · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1720089>)

出口：FINISHED → Explode。isSequence=0。

1. `SetBoolValue(boolVariable="$Do Damage", boolValue="$Nondamaging", everyFrame=false)`

2. `BoolFlip(boolVariable="$Do Damage")`

3. `SetDamageHero(Target="Owner($Damager A)", Enabled="$Do Damage")`

4. `SetDamageHero(Target="Owner($Damager B)", Enabled="$Do Damage")`



### Trobbio Bump Floor (12) / Control [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1732136>)

变量初值：`{"gameObjectVariables":{"Boss Scene":{"fileID":0},"Trobbio":{"fileID":0},"Pt Bump":{"fileID":2164},"Self":{"fileID":1785}}}`

全局迁移：`[]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1732153>)

出口：FINISHED → Idle。isSequence=0。

1. `GetGrandparent(gameObject="Self", storeResult="$Boss Scene")`

2. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Trobbio")`



#### Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1732250>)

出口：BUMP → Bump；OPEN → Open。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=0)`

2. `Trigger2dEvent(gameObject="Self", trigger=0, collideTag=null, sendEvent="BUMP", storeCollider="None")`



#### Bump · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1732366>)

出口：FINISHED → Idle。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=1)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Floor Bump", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `RandomlyFlipScale(gameObject="Self")`

4. `PlayParticleEmitter(gameObject="Owner($Pt Bump)", emit=0, resetIfPlaying=false)`

5. `AudioPlayRandom(gameObject="$Self", audioClips=["GUID:8d58042ab68c2e74c9308549b2d5a392#8300000","GUID:560a0f7cbd86b594098d8d1ae13c9b1b#8300000"], weights=[1,1], pitchMin=0.85, pitchMax=1.15)`



#### Open · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1732542>)

出口：FINISHED → Idle。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=1)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Floor Open", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `FaceObjectV2(objectA="Self", objectB="None", spriteFacesRight=0, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`



### Trobbio Bump Floor (6) / Control [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1734772>)

变量初值：`{"gameObjectVariables":{"Boss Scene":{"fileID":0},"Trobbio":{"fileID":0},"Pt Bump":{"fileID":2168},"Self":{"fileID":1782}}}`

全局迁移：`[]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1734789>)

出口：FINISHED → Idle。isSequence=0。

1. `GetGrandparent(gameObject="Self", storeResult="$Boss Scene")`

2. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Trobbio")`



#### Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1734886>)

出口：BUMP → Bump；OPEN → Open。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=0)`

2. `Trigger2dEvent(gameObject="Self", trigger=0, collideTag=null, sendEvent="BUMP", storeCollider="None")`



#### Bump · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1735002>)

出口：FINISHED → Idle。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=1)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Floor Bump", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `RandomlyFlipScale(gameObject="Self")`

4. `PlayParticleEmitter(gameObject="Owner($Pt Bump)", emit=0, resetIfPlaying=false)`

5. `AudioPlayRandom(gameObject="$Self", audioClips=["GUID:8d58042ab68c2e74c9308549b2d5a392#8300000","GUID:560a0f7cbd86b594098d8d1ae13c9b1b#8300000"], weights=[1,1], pitchMin=0.85, pitchMax=1.15)`



#### Open · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1735178>)

出口：FINISHED → Idle。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=1)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Floor Open", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `FaceObjectV2(objectA="Self", objectB="None", spriteFacesRight=0, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`



### Trobbio Bump Floor (7) / Control [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1735431>)

变量初值：`{"gameObjectVariables":{"Boss Scene":{"fileID":0},"Trobbio":{"fileID":0},"Pt Bump":{"fileID":2169},"Self":{"fileID":1784}}}`

全局迁移：`[]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1735448>)

出口：FINISHED → Idle。isSequence=0。

1. `GetGrandparent(gameObject="Self", storeResult="$Boss Scene")`

2. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Trobbio")`



#### Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1735545>)

出口：BUMP → Bump；OPEN → Open。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=0)`

2. `Trigger2dEvent(gameObject="Self", trigger=0, collideTag=null, sendEvent="BUMP", storeCollider="None")`



#### Bump · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1735661>)

出口：FINISHED → Idle。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=1)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Floor Bump", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `RandomlyFlipScale(gameObject="Self")`

4. `PlayParticleEmitter(gameObject="Owner($Pt Bump)", emit=0, resetIfPlaying=false)`

5. `AudioPlayRandom(gameObject="$Self", audioClips=["GUID:8d58042ab68c2e74c9308549b2d5a392#8300000","GUID:560a0f7cbd86b594098d8d1ae13c9b1b#8300000"], weights=[1,1], pitchMin=0.85, pitchMax=1.15)`



#### Open · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1735837>)

出口：FINISHED → Idle。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=1)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Floor Open", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `FaceObjectV2(objectA="Self", objectB="None", spriteFacesRight=0, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`



### Trobbio Bump Floor (5) / Control [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1736090>)

变量初值：`{"gameObjectVariables":{"Boss Scene":{"fileID":0},"Trobbio":{"fileID":0},"Pt Bump":{"fileID":2150},"Self":{"fileID":1797}}}`

全局迁移：`[]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1736107>)

出口：FINISHED → Idle。isSequence=0。

1. `GetGrandparent(gameObject="Self", storeResult="$Boss Scene")`

2. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Trobbio")`



#### Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1736204>)

出口：BUMP → Bump；OPEN → Open。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=0)`

2. `Trigger2dEvent(gameObject="Self", trigger=0, collideTag=null, sendEvent="BUMP", storeCollider="None")`



#### Bump · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1736320>)

出口：FINISHED → Idle。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=1)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Floor Bump", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `RandomlyFlipScale(gameObject="Self")`

4. `PlayParticleEmitter(gameObject="Owner($Pt Bump)", emit=0, resetIfPlaying=false)`

5. `AudioPlayRandom(gameObject="$Self", audioClips=["GUID:8d58042ab68c2e74c9308549b2d5a392#8300000","GUID:560a0f7cbd86b594098d8d1ae13c9b1b#8300000"], weights=[1,1], pitchMin=0.85, pitchMax=1.15)`



#### Open · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1736496>)

出口：FINISHED → Idle。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=1)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Floor Open", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `FaceObjectV2(objectA="Self", objectB="None", spriteFacesRight=0, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`



### Trobbio Bump Floor (1) / Control [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1736749>)

变量初值：`{"gameObjectVariables":{"Boss Scene":{"fileID":0},"Trobbio":{"fileID":0},"Pt Bump":{"fileID":2151},"Self":{"fileID":1796}}}`

全局迁移：`[]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1736766>)

出口：FINISHED → Idle。isSequence=0。

1. `GetGrandparent(gameObject="Self", storeResult="$Boss Scene")`

2. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Trobbio")`



#### Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1736863>)

出口：BUMP → Bump；OPEN → Open。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=0)`

2. `Trigger2dEvent(gameObject="Self", trigger=0, collideTag=null, sendEvent="BUMP", storeCollider="None")`



#### Bump · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1736979>)

出口：FINISHED → Idle。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=1)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Floor Bump", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `RandomlyFlipScale(gameObject="Self")`

4. `PlayParticleEmitter(gameObject="Owner($Pt Bump)", emit=0, resetIfPlaying=false)`

5. `AudioPlayRandom(gameObject="$Self", audioClips=["GUID:8d58042ab68c2e74c9308549b2d5a392#8300000","GUID:560a0f7cbd86b594098d8d1ae13c9b1b#8300000"], weights=[1,1], pitchMin=0.85, pitchMax=1.15)`



#### Open · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1737155>)

出口：FINISHED → Idle。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=1)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Floor Open", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `FaceObjectV2(objectA="Self", objectB="None", spriteFacesRight=0, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`



### Trobbio Bump Floor (9) / Control [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1737408>)

变量初值：`{"gameObjectVariables":{"Boss Scene":{"fileID":0},"Trobbio":{"fileID":0},"Pt Bump":{"fileID":2149},"Self":{"fileID":1798}}}`

全局迁移：`[]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1737425>)

出口：FINISHED → Idle。isSequence=0。

1. `GetGrandparent(gameObject="Self", storeResult="$Boss Scene")`

2. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Trobbio")`



#### Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1737522>)

出口：BUMP → Bump；OPEN → Open。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=0)`

2. `Trigger2dEvent(gameObject="Self", trigger=0, collideTag=null, sendEvent="BUMP", storeCollider="None")`



#### Bump · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1737638>)

出口：FINISHED → Idle。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=1)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Floor Bump", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `RandomlyFlipScale(gameObject="Self")`

4. `PlayParticleEmitter(gameObject="Owner($Pt Bump)", emit=0, resetIfPlaying=false)`

5. `AudioPlayRandom(gameObject="$Self", audioClips=["GUID:8d58042ab68c2e74c9308549b2d5a392#8300000","GUID:560a0f7cbd86b594098d8d1ae13c9b1b#8300000"], weights=[1,1], pitchMin=0.85, pitchMax=1.15)`



#### Open · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1737814>)

出口：FINISHED → Idle。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=1)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Floor Open", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `FaceObjectV2(objectA="Self", objectB="None", spriteFacesRight=0, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`



### Trobbio Bump Floor (15) / Control [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1738067>)

变量初值：`{"gameObjectVariables":{"Boss Scene":{"fileID":0},"Trobbio":{"fileID":0},"Pt Bump":{"fileID":2155},"Self":{"fileID":1800}}}`

全局迁移：`[]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1738084>)

出口：FINISHED → Idle。isSequence=0。

1. `GetGrandparent(gameObject="Self", storeResult="$Boss Scene")`

2. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Trobbio")`



#### Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1738181>)

出口：BUMP → Bump；OPEN → Open。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=0)`

2. `Trigger2dEvent(gameObject="Self", trigger=0, collideTag=null, sendEvent="BUMP", storeCollider="None")`



#### Bump · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1738297>)

出口：FINISHED → Idle。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=1)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Floor Bump", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `RandomlyFlipScale(gameObject="Self")`

4. `PlayParticleEmitter(gameObject="Owner($Pt Bump)", emit=0, resetIfPlaying=false)`

5. `AudioPlayRandom(gameObject="$Self", audioClips=["GUID:8d58042ab68c2e74c9308549b2d5a392#8300000","GUID:560a0f7cbd86b594098d8d1ae13c9b1b#8300000"], weights=[1,1], pitchMin=0.85, pitchMax=1.15)`



#### Open · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1738473>)

出口：FINISHED → Idle。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=1)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Floor Open", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `FaceObjectV2(objectA="Self", objectB="None", spriteFacesRight=0, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`



### Trobbio Bump Floor (3) / Control [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1738726>)

变量初值：`{"gameObjectVariables":{"Boss Scene":{"fileID":0},"Trobbio":{"fileID":0},"Pt Bump":{"fileID":2152},"Self":{"fileID":1802}}}`

全局迁移：`[]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1738743>)

出口：FINISHED → Idle。isSequence=0。

1. `GetGrandparent(gameObject="Self", storeResult="$Boss Scene")`

2. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Trobbio")`



#### Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1738840>)

出口：BUMP → Bump；OPEN → Open。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=0)`

2. `Trigger2dEvent(gameObject="Self", trigger=0, collideTag=null, sendEvent="BUMP", storeCollider="None")`



#### Bump · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1738956>)

出口：FINISHED → Idle。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=1)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Floor Bump", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `RandomlyFlipScale(gameObject="Self")`

4. `PlayParticleEmitter(gameObject="Owner($Pt Bump)", emit=0, resetIfPlaying=false)`

5. `AudioPlayRandom(gameObject="$Self", audioClips=["GUID:8d58042ab68c2e74c9308549b2d5a392#8300000","GUID:560a0f7cbd86b594098d8d1ae13c9b1b#8300000"], weights=[1,1], pitchMin=0.85, pitchMax=1.15)`



#### Open · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1739132>)

出口：FINISHED → Idle。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=1)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Floor Open", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `FaceObjectV2(objectA="Self", objectB="None", spriteFacesRight=0, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`



### Trobbio Bump Floor (11) / Control [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1739385>)

变量初值：`{"gameObjectVariables":{"Boss Scene":{"fileID":0},"Trobbio":{"fileID":0},"Pt Bump":{"fileID":2153},"Self":{"fileID":1801}}}`

全局迁移：`[]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1739402>)

出口：FINISHED → Idle。isSequence=0。

1. `GetGrandparent(gameObject="Self", storeResult="$Boss Scene")`

2. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Trobbio")`



#### Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1739499>)

出口：BUMP → Bump；OPEN → Open。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=0)`

2. `Trigger2dEvent(gameObject="Self", trigger=0, collideTag=null, sendEvent="BUMP", storeCollider="None")`



#### Bump · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1739615>)

出口：FINISHED → Idle。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=1)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Floor Bump", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `RandomlyFlipScale(gameObject="Self")`

4. `PlayParticleEmitter(gameObject="Owner($Pt Bump)", emit=0, resetIfPlaying=false)`

5. `AudioPlayRandom(gameObject="$Self", audioClips=["GUID:8d58042ab68c2e74c9308549b2d5a392#8300000","GUID:560a0f7cbd86b594098d8d1ae13c9b1b#8300000"], weights=[1,1], pitchMin=0.85, pitchMax=1.15)`



#### Open · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1739791>)

出口：FINISHED → Idle。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=1)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Floor Open", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `FaceObjectV2(objectA="Self", objectB="None", spriteFacesRight=0, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`



### Trobbio Bump Floor (10) / Control [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1743339>)

变量初值：`{"gameObjectVariables":{"Boss Scene":{"fileID":0},"Trobbio":{"fileID":0},"Pt Bump":{"fileID":2163},"Self":{"fileID":1792}}}`

全局迁移：`[]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1743356>)

出口：FINISHED → Idle。isSequence=0。

1. `GetGrandparent(gameObject="Self", storeResult="$Boss Scene")`

2. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Trobbio")`



#### Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1743453>)

出口：BUMP → Bump；OPEN → Open。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=0)`

2. `Trigger2dEvent(gameObject="Self", trigger=0, collideTag=null, sendEvent="BUMP", storeCollider="None")`



#### Bump · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1743569>)

出口：FINISHED → Idle。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=1)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Floor Bump", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `RandomlyFlipScale(gameObject="Self")`

4. `PlayParticleEmitter(gameObject="Owner($Pt Bump)", emit=0, resetIfPlaying=false)`

5. `AudioPlayRandom(gameObject="$Self", audioClips=["GUID:8d58042ab68c2e74c9308549b2d5a392#8300000","GUID:560a0f7cbd86b594098d8d1ae13c9b1b#8300000"], weights=[1,1], pitchMin=0.85, pitchMax=1.15)`



#### Open · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1743745>)

出口：FINISHED → Idle。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=1)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Floor Open", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `FaceObjectV2(objectA="Self", objectB="None", spriteFacesRight=0, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`



### Trobbio Bump Floor (2) / Control [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1745975>)

变量初值：`{"gameObjectVariables":{"Boss Scene":{"fileID":0},"Trobbio":{"fileID":0},"Pt Bump":{"fileID":2140},"Self":{"fileID":1809}}}`

全局迁移：`[]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1745992>)

出口：FINISHED → Idle。isSequence=0。

1. `GetGrandparent(gameObject="Self", storeResult="$Boss Scene")`

2. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Trobbio")`



#### Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1746089>)

出口：BUMP → Bump；OPEN → Open。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=0)`

2. `Trigger2dEvent(gameObject="Self", trigger=0, collideTag=null, sendEvent="BUMP", storeCollider="None")`



#### Bump · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1746205>)

出口：FINISHED → Idle。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=1)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Floor Bump", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `RandomlyFlipScale(gameObject="Self")`

4. `PlayParticleEmitter(gameObject="Owner($Pt Bump)", emit=0, resetIfPlaying=false)`

5. `AudioPlayRandom(gameObject="$Self", audioClips=["GUID:8d58042ab68c2e74c9308549b2d5a392#8300000","GUID:560a0f7cbd86b594098d8d1ae13c9b1b#8300000"], weights=[1,1], pitchMin=0.85, pitchMax=1.15)`



#### Open · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1746381>)

出口：FINISHED → Idle。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=1)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Floor Open", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `FaceObjectV2(objectA="Self", objectB="None", spriteFacesRight=0, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`



### Trobbio Bump Floor (14) / Control [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1747293>)

变量初值：`{"gameObjectVariables":{"Boss Scene":{"fileID":0},"Trobbio":{"fileID":0},"Pt Bump":{"fileID":2142},"Self":{"fileID":1811}}}`

全局迁移：`[]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1747310>)

出口：FINISHED → Idle。isSequence=0。

1. `GetGrandparent(gameObject="Self", storeResult="$Boss Scene")`

2. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Trobbio")`



#### Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1747407>)

出口：BUMP → Bump；OPEN → Open。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=0)`

2. `Trigger2dEvent(gameObject="Self", trigger=0, collideTag=null, sendEvent="BUMP", storeCollider="None")`



#### Bump · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1747523>)

出口：FINISHED → Idle。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=1)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Floor Bump", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `RandomlyFlipScale(gameObject="Self")`

4. `PlayParticleEmitter(gameObject="Owner($Pt Bump)", emit=0, resetIfPlaying=false)`

5. `AudioPlayRandom(gameObject="$Self", audioClips=["GUID:8d58042ab68c2e74c9308549b2d5a392#8300000","GUID:560a0f7cbd86b594098d8d1ae13c9b1b#8300000"], weights=[1,1], pitchMin=0.85, pitchMax=1.15)`



#### Open · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1747699>)

出口：FINISHED → Idle。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=1)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Floor Open", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `FaceObjectV2(objectA="Self", objectB="None", spriteFacesRight=0, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`



### Trobbio Bump Floor (13) / Control [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1748611>)

变量初值：`{"gameObjectVariables":{"Boss Scene":{"fileID":0},"Trobbio":{"fileID":0},"Pt Bump":{"fileID":2144},"Self":{"fileID":1803}}}`

全局迁移：`[]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1748628>)

出口：FINISHED → Idle。isSequence=0。

1. `GetGrandparent(gameObject="Self", storeResult="$Boss Scene")`

2. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Trobbio")`



#### Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1748725>)

出口：BUMP → Bump；OPEN → Open。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=0)`

2. `Trigger2dEvent(gameObject="Self", trigger=0, collideTag=null, sendEvent="BUMP", storeCollider="None")`



#### Bump · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1748841>)

出口：FINISHED → Idle。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=1)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Floor Bump", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `RandomlyFlipScale(gameObject="Self")`

4. `PlayParticleEmitter(gameObject="Owner($Pt Bump)", emit=0, resetIfPlaying=false)`

5. `AudioPlayRandom(gameObject="$Self", audioClips=["GUID:8d58042ab68c2e74c9308549b2d5a392#8300000","GUID:560a0f7cbd86b594098d8d1ae13c9b1b#8300000"], weights=[1,1], pitchMin=0.85, pitchMax=1.15)`



#### Open · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1749017>)

出口：FINISHED → Idle。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=1)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Floor Open", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `FaceObjectV2(objectA="Self", objectB="None", spriteFacesRight=0, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`



### Trobbio Bump Floor / Control [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1749270>)

变量初值：`{"gameObjectVariables":{"Boss Scene":{"fileID":0},"Trobbio":{"fileID":0},"Pt Bump":{"fileID":2147},"Self":{"fileID":1806}}}`

全局迁移：`[]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1749287>)

出口：FINISHED → Idle。isSequence=0。

1. `GetGrandparent(gameObject="Self", storeResult="$Boss Scene")`

2. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Trobbio")`



#### Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1749384>)

出口：BUMP → Bump；OPEN → Open。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=0)`

2. `Trigger2dEvent(gameObject="Self", trigger=0, collideTag=null, sendEvent="BUMP", storeCollider="None")`



#### Bump · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1749500>)

出口：FINISHED → Idle。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=1)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Floor Bump", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `RandomlyFlipScale(gameObject="Self")`

4. `PlayParticleEmitter(gameObject="Owner($Pt Bump)", emit=0, resetIfPlaying=false)`

5. `AudioPlayRandom(gameObject="$Self", audioClips=["GUID:8d58042ab68c2e74c9308549b2d5a392#8300000","GUID:560a0f7cbd86b594098d8d1ae13c9b1b#8300000"], weights=[1,1], pitchMin=0.85, pitchMax=1.15)`



#### Open · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1749676>)

出口：FINISHED → Idle。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=1)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Floor Open", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `FaceObjectV2(objectA="Self", objectB="None", spriteFacesRight=0, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`



### Trobbio Bump Floor (4) / Control [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1749929>)

变量初值：`{"gameObjectVariables":{"Boss Scene":{"fileID":0},"Trobbio":{"fileID":0},"Pt Bump":{"fileID":2148},"Self":{"fileID":1805}}}`

全局迁移：`[]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1749946>)

出口：FINISHED → Idle。isSequence=0。

1. `GetGrandparent(gameObject="Self", storeResult="$Boss Scene")`

2. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Trobbio")`



#### Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1750043>)

出口：BUMP → Bump；OPEN → Open。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=0)`

2. `Trigger2dEvent(gameObject="Self", trigger=0, collideTag=null, sendEvent="BUMP", storeCollider="None")`



#### Bump · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1750159>)

出口：FINISHED → Idle。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=1)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Floor Bump", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `RandomlyFlipScale(gameObject="Self")`

4. `PlayParticleEmitter(gameObject="Owner($Pt Bump)", emit=0, resetIfPlaying=false)`

5. `AudioPlayRandom(gameObject="$Self", audioClips=["GUID:8d58042ab68c2e74c9308549b2d5a392#8300000","GUID:560a0f7cbd86b594098d8d1ae13c9b1b#8300000"], weights=[1,1], pitchMin=0.85, pitchMax=1.15)`



#### Open · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1750335>)

出口：FINISHED → Idle。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=1)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Floor Open", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `FaceObjectV2(objectA="Self", objectB="None", spriteFacesRight=0, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`



### Trobbio Bump Floor (8) / Control [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1751906>)

变量初值：`{"gameObjectVariables":{"Boss Scene":{"fileID":0},"Trobbio":{"fileID":0},"Pt Bump":{"fileID":2138},"Self":{"fileID":1812}}}`

全局迁移：`[]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1751923>)

出口：FINISHED → Idle。isSequence=0。

1. `GetGrandparent(gameObject="Self", storeResult="$Boss Scene")`

2. `FindNamedChild(gameObject="Owner($Boss Scene)", storeResult="$Trobbio")`



#### Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1752020>)

出口：BUMP → Bump；OPEN → Open。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=0)`

2. `Trigger2dEvent(gameObject="Self", trigger=0, collideTag=null, sendEvent="BUMP", storeCollider="None")`



#### Bump · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1752136>)

出口：FINISHED → Idle。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=1)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Floor Bump", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `RandomlyFlipScale(gameObject="Self")`

4. `PlayParticleEmitter(gameObject="Owner($Pt Bump)", emit=0, resetIfPlaying=false)`

5. `AudioPlayRandom(gameObject="$Self", audioClips=["GUID:8d58042ab68c2e74c9308549b2d5a392#8300000","GUID:560a0f7cbd86b594098d8d1ae13c9b1b#8300000"], weights=[1,1], pitchMin=0.85, pitchMax=1.15)`



#### Open · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1752312>)

出口：FINISHED → Idle。isSequence=0。

1. `SetMeshRenderer(gameObject="Self", active=1)`

2. `Tk2dPlayAnimationWithEvents(gameObject="Self", clipName="Floor Open", animationTriggerEvent=null, animationCompleteEvent="FINISHED")`

3. `FaceObjectV2(objectA="Self", objectB="None", spriteFacesRight=0, playNewAnimation=false, newAnimationClip=null, resetFrame=false, everyFrame=false, pauseBetweenTurns=0.5)`



### Tornado Damager / FSM [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1753354>)

变量初值：`{"boolVariables":{"Black Threaded":0,"Did Bind Bell Hit":0,"Hazard Hit":0,"Hero Parrying":0,"Ignore Parrying":0,"z2 Steam Hazard":0,"z3 Force Black Threaded":0},"stringVariables":{"Hero Event":null,"Hero Event Hazard":null},"gameObjectVariables":{"Self":{"fileID":0},"Parent":{"fileID":0},"Grandparent":{"fileID":0},"Collider":{"fileID":0},"Great Grandparent":{"fileID":0}},"enumVariables":{"Multihit Type":null}}`

全局迁移：`[]`

#### Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1753371>)

出口：COLLIDE → Hit；PARRIED → Parried Recover；TINK DOWN → Tink D。isSequence=0。

1. **disabled** `Collision2dEvent(gameObject="Self", collision=0, collideTag=null, sendEvent="HIT", storeCollider="None", storeForce="None")`

2. `Trigger2dEventLayer(trigger=1, collideTag="None", collideLayer=20, sendEvent="COLLIDE", storeCollider="$Collider")`

3. `Trigger2dEventLayer(trigger=0, collideTag="None", collideLayer=20, sendEvent="COLLIDE", storeCollider="None")`



#### Hit · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1753537>)

出口：END → Idle；BELL BIND → Bell Bind Hit；HAZARD → Hazard Hit；CROSS STITCH → Cross Stitch Parry；CANCEL → Idle；PARRIED → Parried Recover。isSequence=0。

1. `PlayerDataBoolTest(boolName="isInvincible", isTrue="CANCEL", isFalse=null)`

2. `BoolTest(boolVariable="$Hazard Hit", isTrue="HAZARD", isFalse=null, everyFrame=false)`

3. `GetHeroCState(VariableName="parrying", StoreValue="$Hero Parrying", EveryFrame=false)`

4. `BoolTestMulti(boolVariables=["$Hero Parrying","$Ignore Parrying"], boolStates=[1,0], trueEvent="CROSS STITCH", falseEvent=null, storeResult="None", everyFrame=false)`

5. `HeroControllerMethods(method=28, parameters=[], everyFrame=0, storeValue={"variableName":null,"objectType":null,"useVariable":1,"type":2,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}, isTrue="PARRIED", isFalse=null)`

6. `CanHeroTakeDamage(eventTarget={"target":0,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, canTakeDmgEvent=null, cannotTakeDmgEvent="CANCEL")`

7. `CallMethodProper(gameObject="Owner($Hero)", behaviour="HeroController", methodName="WillDoBellBindHit", parameters=[], storeResult={"variableName":"Did Bind Bell Hit","objectType":"UnityEngine.Object","useVariable":1,"type":2,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}, EveryFrame=false)`

8. `BoolTest(boolVariable="$Did Bind Bell Hit", isTrue="BELL BIND", isFalse=null, everyFrame=false)`

9. `SetFsmBool(gameObject="Owner($Hero)", fsmName="Roar and Wound States", variableName="Damaged By Void Multihitter", setValue="$Black Threaded", everyFrame=false)`

10. `SetFsmGameObject(gameObject="Owner($Hero)", fsmName="Roar and Wound States", variableName="Multi Wounder", setValue="$Self", everyFrame=false)`

11. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Self","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="MULTI HIT CONNECT", delay=0, everyFrame=false)`

12. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Parent)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="MULTI HIT CONNECT", delay=0, everyFrame=false)`

13. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Grandparent)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="MULTI HIT CONNECT", delay=0, everyFrame=false)`

14. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Great Grandparent)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="MULTI HIT CONNECT", delay=0, everyFrame=false)`

15. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Hero)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="$Hero Event", delay=0, everyFrame=false)`

16. `PlayAudioEvent(audioClip="GUID:4eb2dcf0a2710824593125919c824fad#8300000", pitchMin=1.2, pitchMax=1.2, volume=1, audioPlayerPrefab="None", spawnPoint="Owner($Hero)", spawnPosition={"x":0,"y":0,"z":0}, SpawnedPlayerRef="None")`

17. `SpawnObjectFromGlobalPool(gameObject="GUID:44420f5c4d1e25046915d33577224b36#1709254077376921", spawnPoint="$Hero", position="None", rotation="None", storeObject="None")`

18. `Wait(time=0.1, finishEvent="END", realTime=false)`



#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1754307>)

出口：FINISHED → Check Black Threaded。isSequence=0。

1. `GetOwner(storeGameObject="$Self")`

2. `GetParent(gameObject="Self", storeResult="$Parent")`

3. `GetGrandparent(gameObject="Self", storeResult="$Grandparent")`

4. `GetParent(gameObject="Owner($Grandparent)", storeResult="$Great Grandparent")`

5. `WaitForHeroInPosition(sendEvent="FINISHED", skipIfAlreadyPositioned=1)`



#### Parried Recover · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1754442>)

出口：FINISHED → Idle；PARRIED → Parried Recover。isSequence=0。

1. `Wait(time=0.3, finishEvent="FINISHED", realTime=false)`



#### Bell Bind Hit · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1754524>)

出口：FINISHED → Idle。isSequence=0。

1. `DamageHeroDirectly(damager="Self", damageAmount=1, spikeHazard=false, sinkHazard=false)`

2. `SendEventByNameUpwards(Target="Self", EventName="CANCEL MULTI HIT")`



#### Hazard Hit · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1754623>)

出口：FINISHED → Idle。isSequence=1。

1. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Hero)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="$Hero Event Hazard", delay=0, everyFrame=false)`

2. `Wait(time=0.3, finishEvent=null, realTime=false)`

3. `DamageHeroDirectly(damager="Self", damageAmount=1, spikeHazard=true, sinkHazard=false)`

4. `Wait(time=1.35, finishEvent=null, realTime=false)`



#### Cross Stitch Parry · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1754778>)

出口：FINISHED → Parried Recover。isSequence=0。

1. `SendEventByName(eventTarget={"target":1,"excludeSelf":0,"gameObject":"Owner($Hero)","fsmName":null,"sendToChildren":0,"fsmComponent":"fileID:0"}, sendEvent="PARRIED", delay=0, everyFrame=false)`



#### Check Steam Hazard · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1754889>)

出口：FINISHED → Set Tink Event。isSequence=0。

1. `SetStringValue(stringVariable="$Hero Event Hazard", stringValue="MULTI WOUND HAZARD", everyFrame=false)`

2. `BoolTest(boolVariable="$z2 Steam Hazard", isTrue=null, isFalse="FINISHED", everyFrame=false)`

3. `SetBoolValue(boolVariable="$Hazard Hit", boolValue=1, everyFrame=false)`

4. `SetStringValue(stringVariable="$Hero Event Hazard", stringValue="MULTI WOUND STEAM", everyFrame=false)`



#### Check Dmg Hero Event · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1755015>)

出口：FINISHED → Idle；LAG HIT → Set Lag Hit；ZAP HIT → Set Zap Hit；DOUBLE STRIKE → Set Double Strike；POLLEN → Set Pollen Hit；NO EFFECT → Set No Effect；WEAK → Set Weak。isSequence=0。

1. `SetStringValue(stringVariable="$Hero Event", stringValue="MULTI WOUND 3", everyFrame=false)`

2. `EnumCompare(enumVariable="$Multihit Type", compareTo=1, equalEvent="LAG HIT", notEqualEvent=null, storeResult="None", everyFrame=false)`

3. `EnumCompare(enumVariable="$Multihit Type", compareTo=2, equalEvent="ZAP HIT", notEqualEvent=null, storeResult="None", everyFrame=false)`

4. `EnumCompare(enumVariable="$Multihit Type", compareTo=3, equalEvent="DOUBLE STRIKE", notEqualEvent=null, storeResult="None", everyFrame=false)`

5. `EnumCompare(enumVariable="$Multihit Type", compareTo=4, equalEvent="POLLEN", notEqualEvent=null, storeResult="None", everyFrame=false)`

6. `EnumCompare(enumVariable="$Multihit Type", compareTo=5, equalEvent="NO EFFECT", notEqualEvent=null, storeResult="None", everyFrame=false)`

7. `EnumCompare(enumVariable="$Multihit Type", compareTo=6, equalEvent="WEAK", notEqualEvent=null, storeResult="None", everyFrame=false)`



#### Set Lag Hit · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1755327>)

出口：FINISHED → Idle。isSequence=0。

1. `SetStringValue(stringVariable="$Hero Event", stringValue="MULTI LAG HIT", everyFrame=false)`



#### Set Zap Hit · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1755405>)

出口：FINISHED → Idle。isSequence=0。

1. `SetStringValue(stringVariable="$Hero Event", stringValue="MULTI ZAP HIT", everyFrame=false)`



#### Set Double Strike · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1755483>)

出口：FINISHED → Idle。isSequence=0。

1. `SetStringValue(stringVariable="$Hero Event", stringValue="MULTI DOUBLE STRIKE", everyFrame=false)`



#### Set Tink Event · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1755561>)

出口：FINISHED → Check Dmg Hero Event。isSequence=0。

1. `HasComponent(gameObject="Self", component="TinkEffect", removeOnExit=0, trueEvent=null, falseEvent="FINISHED", store="None", everyFrame=false)`

2. `CallMethodProper(gameObject="Self", behaviour="TinkEffect", methodName="SetFsmEvent", parameters=[{"variableName":null,"objectType":null,"useVariable":0,"type":4,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":"TINKED","vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}], storeResult={"variableName":null,"objectType":null,"useVariable":1,"type":-1,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}, EveryFrame=false)`

3. `CallMethodProper(gameObject="Self", behaviour="TinkEffect", methodName="SetSendDirectionalFSMEvents", parameters=[{"variableName":null,"objectType":null,"useVariable":0,"type":2,"floatValue":0,"intValue":0,"boolValue":1,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}], storeResult={"variableName":null,"objectType":null,"useVariable":1,"type":-1,"floatValue":0,"intValue":0,"boolValue":0,"stringValue":null,"vector4Value":{"x":0,"y":0,"z":0,"w":0},"objectReference":"fileID:0","arrayValue":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":null,"floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}}, EveryFrame=false)`



#### Check Black Threaded · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1755815>)

出口：FINISHED → Check Steam Hazard。isSequence=0。

1. `CheckIsBlackThreaded(Target="Self", TrueEvent=null, FalseEvent=null, StoreValue="$Black Threaded", EveryFrame=false)`

2. `BoolTest(boolVariable="$z3 Force Black Threaded", isTrue=null, isFalse="FINISHED", everyFrame=false)`

3. `SetBoolValue(boolVariable="$Black Threaded", boolValue=1, everyFrame=false)`



#### Set Pollen Hit · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1755930>)

出口：FINISHED → Idle。isSequence=0。

1. `SetStringValue(stringVariable="$Hero Event", stringValue="MULTI POLLEN HIT", everyFrame=false)`



#### Tink D · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1756008>)

出口：FINISHED → Idle。isSequence=0。

1. `Wait(time=0.1, finishEvent="FINISHED", realTime=false)`



#### Set No Effect · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1756081>)

出口：FINISHED → Idle。isSequence=0。

1. `SetStringValue(stringVariable="$Hero Event", stringValue="MULTI HIT NO EFFECT", everyFrame=false)`



#### Set Weak · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1756159>)

出口：FINISHED → Idle。isSequence=0。

1. `SetStringValue(stringVariable="$Hero Event", stringValue="MULTI WOUND WEAK", everyFrame=false)`

2. `SetStringValue(stringVariable="$Hero Event Hazard", stringValue="MULTI WOUND HAZARD WEAK", everyFrame=false)`



### Audio Boss Tension / Control [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1760965>)

变量初值：`{"floatVariables":{"Delay":0}}`

全局迁移：`[]`

#### Init · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1760982>)

出口：FINISHED → Idle。isSequence=0。



#### Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1761043>)

出口：ENTER → Delay。isSequence=0。

1. `Trigger2dEvent(gameObject="Self", trigger=1, collideTag=null, sendEvent="ENTER", storeCollider="None")`

2. `FadeAudio(gameObject="Self", startVolume=1, endVolume=0, time=6)`



#### Play Tension · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1761164>)

出口：TENSION END → Stop Tension；LEAVING SCENE → Stop Tension；PAUSE TENSION → Idle。isSequence=0。

1. `AudioPlaySimple(gameObject="Self", volume=0, oneShotClip="fileID:0")`

2. `FadeAudio(gameObject="Self", startVolume=0, endVolume=1, time=6)`



#### Stop Tension · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1761301>)

出口：无本地迁移（持续/外部驱动）。isSequence=0。

1. `AudioStopV2(gameObject="Self", fadeTime=1, cancelOnEarlyExit=false)`



#### Delay · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1761372>)

出口：FINISHED → Play Tension；LEAVING SCENE → Stop Tension；TENSION END → Stop Tension；PAUSE TENSION → Idle。isSequence=0。

1. `Wait(time="$Delay", finishEvent="FINISHED", realTime=false)`



### Tornado Event Sender / Tornado Event Sender [scene_context_fsms]

[源文件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1766187>)

变量初值：`{"gameObjectVariables":{"Collider":{"fileID":0}}}`

全局迁移：`[]`

#### Idle · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1766204>)

出口：TRIGGER → Send。isSequence=0。

1. `Trigger2dEvent(gameObject="Self", trigger=0, collideTag=null, sendEvent="TRIGGER", storeCollider="$Collider")`



#### Send · [证据](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1766293>)

出口：FINISHED → Idle。isSequence=0。

1. `SendEventByNameUpwards(Target="Owner($Collider)", EventName="TORNADO")`

2. `SendMessage(gameObject="Owner($Collider)", delivery=0, options=1, functionCall={"FunctionName":"TornadoEffect","parameterType":"None","BoolParameter":0,"FloatParameter":0,"IntParameter":0,"GameObjectParameter":"fileID:0","ObjectParameter":"fileID:0","StringParameter":null,"Vector2Parameter":{"x":0,"y":0},"Vector3Parameter":{"x":0,"y":0,"z":0},"RectParamater":{"serializedVersion":2,"x":0,"y":0,"width":0,"height":0},"QuaternionParameter":{"x":0,"y":0,"z":0,"w":0},"MaterialParameter":"fileID:0","TextureParameter":"fileID:0","ColorParameter":{"r":0,"g":0,"b":0,"a":1},"EnumParameter":0,"ArrayParameter":{"useVariable":0,"name":null,"tooltip":null,"showInInspector":0,"networkSync":0,"type":-1,"objectTypeName":"UnityEngine.Object","floatValues":[],"intValues":null,"boolValues":null,"stringValues":[],"vector4Values":[],"objectReferences":[]}})`



### 动画事件索引

[动画库](</Users/mars/workspace/SilksongUnity6/Assets/Animations/Hornet Enemies/Trobbio Anim.prefab:1>)

|Clip|帧数|fps|wrapMode|loopStart|触发索引0基/标称秒|
|---|---:|---:|---:|---:|---|

|Bomb Idle|1|12|0|0||

|Antic|3|12|2|0||

|Flash Attack|10|13|2|0|4/0.307692, 5/0.384615|

|Attack Throw Air|10|12|2|0|6/0.5|

|Tornado|8|15|1|4||

|Death Fan|4|12|0|0||

|Enter|6|18|2|0|2/0.111111|

|Evade|5|12|1|1||

|Exit|7|20|2|0|4/0.2|

|Fly|6|12|0|1||

|Idle|10|12|0|0||

|Tornado Projectile|7|12|1|1|1/0.083333|

|Stun|9|12|2|0||

|Throw|10|12|2|0|6/0.5|

|Bomb Blow|1|15|2|0||

|Recover|3|12|2|0||

|Land|3|12|2|0||

|Floor Bump|6|20|2|0||

|Bomb Antic|3|18|0|0||

|Bomb Blast|7|30|2|0||

|Tornado End|4|12|2|0||

|Pose 1|3|12|2|0||

|Pose 2|3|12|2|0||

|Pose 3|3|12|2|0||

|Tornado Projectile End|1|12|2|0||

|Tornado Disperse|4|24|2|0||

|Idle Spin|4|12|2|0||

|Jump|5|12|2|0||

|Fly Antic|3|12|2|0||

|Fall|3|12|2|0||

|Jump Antic|4|10|2|0||

|Drop Antic|1|12|2|0||

|Floor Open|6|15|2|0||

|Stun Air|3|12|0|0||

|Stun Land|6|12|1|2||

|Death Pose 3|2|12|0|0||

|Stun Hit|7|12|1|3||

|Stun Recover|3|12|2|0||

|Flash Attack Intro|6|12|2|0|1/0.083333|

|Death Pose 1|3|12|1|1||

|Death Pose 2|2|12|0|1||

|Death Collapse|3|12|2|0||

|Death Startle|3|15|2|0||

|Tornado Evade|8|18|2|0|6/0.333333|

|Land Quick|2|15|2|0||

|Phase Roar|6|12|1|4|4/0.333333|

|Flash Attack Air|10|13|2|0|4/0.307692, 5/0.384615|

|Sing|6|12|1|4|4/0.333333|

|Death Pose Final|2|14|0|0||

|Pose Victory|8|13|1|6||

|Tornado Antic|4|15|2|0||


### 物理、伤害与碰撞组件定位

#### Trobbio [组件50833703512093738](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:1075>)

```yaml
Rigidbody2D:
  serializedVersion: 5
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1709254077376921}
  m_BodyType: 1
  m_Simulated: 1
  m_UseFullKinematicContacts: 0
  m_UseAutoMass: 0
  m_Mass: 1
  m_LinearDamping: 0
  m_AngularDamping: 0.05
  m_GravityScale: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_Interpolate: 0
  m_SleepingMode: 0
  m_CollisionDetection: 1
  m_Constraints: 4
```

#### Trobbio [组件61436073260064126](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:1235>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1709254077376921}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 0
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0.09514618, y: -1.9212875}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 1.2368622, y: 2.8945122}
  m_EdgeRadius: 0
```

#### Trobbio [组件114571718729274231](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:1397>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1709254077376921}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 7e0b9799fb0157646caefd91bc67f0a6, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  audioPlayerPrefab: {fileID: 82724804207875695, guid: 99068b2a95bddff419cb6f176648d4e6, type: 2}
  regularInvincibleAudio:
    Clip: {fileID: 0}
    PitchMin: 0.75
    PitchMax: 1.25
    Volume: 1
    vibrationDataAsset: {fileID: 0}
  blockHitPrefab: {fileID: 1709254077376921, guid: e3986d204468fc44ebaf84af5df3fdfa, type: 2}
  strikeNailPrefab: {fileID: 1709254077376921, guid: 64c20baf394ac9a41b03deea82568445, type: 2}
  slashImpactPrefab: {fileID: 1709254077376921, guid: 97c9ba031f06bae4681d3fda13c3f87b, type: 2}
  corpseSplatPrefab: {fileID: 1709254077376921, guid: ee26d04f9efdaa7458f4fcea07e485df, type: 2}
  hp: 700
  damageScaling:
    Level1Mult: 1.4
    Level2Mult: 1
    Level3Mult: 0.9
    Level4Mult: 0.8
    Level5Mult: 0.8
  enemyType: 0
  doNotGiveSilk: 0
  ignoreFlags: 0
  reaperBundles: 0
  effectOrigin: {x: 0, y: -0.2, z: 0}
  ignoreKillAll: 0
  sendDamageTo: {fileID: 0}
  isPartOfSendToTarget: 0
  tagDamageTakerIgnoreColliderState: 0
  takeTagDamageWhileInvincible: 0
  targetPointOverride: {fileID: 0}
  battleScene: {fileID: 0}
  sendHitTo: {fileID: 0}
  sendKilledToObject: {fileID: 0}
  sendKilledToName:
  smallGeoDrops: 0
  mediumGeoDrops: 0
  largeGeoDrops: 0
  largeSmoothGeoDrops: 0
  megaFlingGeo: 0
  shellShardDrops: 0
  flingSilkOrbsDown: 0
  flingSilkOrbsAimObject: {fileID: 0}
  itemDropGroups: []
  _itemDropProbability: 0
  _itemDrops: []
  hasAlternateHitAnimation: 0
  alternateHitAnimation: False
  invincible: 0
  piercable: 0
  invincibleFromDirection: 0
  preventInvincibleEffect: 1
  preventInvincibleShake: 0
  preventInvincibleAttackBlock: 1
  invincibleRecoil: 0
  dontSendTinkToDamager: 0
  hasAlternateInvincibleSound: 0
  alternateInvincibleSound: {fileID: 0}
  immuneToNailAttacks: 0
  immuneToExplosions: 0
  immuneToBeams: 0
  immuneToHunterWeapon: 0
  immuneToCoal: 0
  immuneToTraps: 0
  immuneToWater: 0
  immuneToSpikes: 0
  immuneToLava: 0
  isMossExtractable: 0
  isSwampExtractable: 0
  isBluebloodExtractable: 0
  deathAudioSnapshot: {fileID: 0}
  hasSpecialDeath: 1
  deathReset: 0
  damageOverride: 0
  ignoreAcid: 0
  ignoreWater: 0
  zeroHPEventOverride: {fileID: 0}
  dontDropMeat: 1
  enemySize: 1
  bigEnemyDeath: 0
  preventDeathAfterHero: 1
  ignoreHazards: 0
  invulnerableTime: 0.25
  semiPersistent: 0
  isDead: 0
  ignorePersistence: 0
  tinkTimer: 0
```

#### Damager [组件114208575754630950](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:43531>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1061268324235159}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 49c386a20fdaa83a59c1a091a909e14c, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  damageDealt: 1
  hazardType: 1
  damageAsset: {fileID: 0}
  damagePropertyFlags: 0
  resetOnEnable: 0
  canClashTink: 0
  forceParry: 0
  noClashFreeze: 0
  noTerrainThunk: 0
  noTerrainRecoil: 0
  noCorpseSpikeStick: 0
  noBounceCooldown: 0
  overrideCollisionSide: 0
  collisionSide: 0
  invertCollisionSide: 0
  HeroDamagedFSM: {fileID: 0}
  AlwaysSendDamaged: 0
  HeroDamagedFSMEvent:
  HeroDamagedFSMBool:
  HeroDamagedFSMGameObject:
  ClashEvents:
    OnClashUp:
      m_PersistentCalls:
        m_Calls: []
    OnClashDown:
      m_PersistentCalls:
        m_Calls: []
    OnClashLeft:
      m_PersistentCalls:
        m_Calls: []
    OnClashRight:
      m_PersistentCalls:
        m_Calls: []
  OnDamagedHero:
    m_PersistentCalls:
      m_Calls: []
```

#### Damager [组件58431740505123533](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:43579>)

```yaml
CircleCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1061268324235159}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_Radius: 2.03
```

#### Tornado Damager [组件60194081240383615](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:46081>)

```yaml
PolygonCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1372920208702427}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Points:
    m_Paths:
    - - {x: 0, y: -0.5242195}
      - {x: -1.5740967, y: -1.1039467}
      - {x: 0.11312866, y: -3.634944}
      - {x: 1.6335983, y: -1.0760336}
  m_UseDelaunayMesh: 0
```

#### Damage Collider [组件114855482821919830](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:46346>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1025901758691103}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 49c386a20fdaa83a59c1a091a909e14c, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  damageDealt: 1
  hazardType: 1
  damageAsset: {fileID: 0}
  damagePropertyFlags: 0
  resetOnEnable: 0
  canClashTink: 0
  forceParry: 0
  noClashFreeze: 0
  noTerrainThunk: 0
  noTerrainRecoil: 0
  noCorpseSpikeStick: 0
  noBounceCooldown: 0
  overrideCollisionSide: 0
  collisionSide: 0
  invertCollisionSide: 0
  HeroDamagedFSM: {fileID: 0}
  AlwaysSendDamaged: 0
  HeroDamagedFSMEvent:
  HeroDamagedFSMBool:
  HeroDamagedFSMGameObject:
  ClashEvents:
    OnClashUp:
      m_PersistentCalls:
        m_Calls: []
    OnClashDown:
      m_PersistentCalls:
        m_Calls: []
    OnClashLeft:
      m_PersistentCalls:
        m_Calls: []
    OnClashRight:
      m_PersistentCalls:
        m_Calls: []
  OnDamagedHero:
    m_PersistentCalls:
      m_Calls: []
```

#### Damage Collider [组件61492842699383957](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:46394>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1025901758691103}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 0
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0.09514618, y: -1.390789}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 1.2368622, y: 1.8008728}
  m_EdgeRadius: 0
```

#### Floor Bouncer [组件61880619614767448](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:46455>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1985305603660343}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 0
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0.09514618, y: -1.9212875}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 1.2368622, y: 2.8945122}
  m_EdgeRadius: 0
```

#### FakeDeath Range [组件61295926465608920](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:76959>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1694121525821480}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0.5142908}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 35, y: 21.96}
  m_EdgeRadius: 0
```

#### FakeDeath ExitRange [组件61181586030114204](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:77054>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1320256170494724}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0.5142908}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 45, y: 21.96}
  m_EdgeRadius: 0
```

#### Flinch Detector [组件61842968619709538](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:77339>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1217368724061974}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0.5271344, y: 1.0428123}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 6.7442694, y: 3.0856247}
  m_EdgeRadius: 0
```

#### Evade Range [组件61932862749439555](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:77694>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1808113985169905}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: -0.9790878}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 14, y: 8.047867}
  m_EdgeRadius: 0
```

#### Evade Tornado Range [组件61197515695889172](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:77775>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1060945828524476}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0.99629784}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 10, y: 4.0970955}
  m_EdgeRadius: 0
```

#### Terrain Saver [组件61201141531394087](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:77836>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1900271049623953}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 0
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0.09514618, y: -1.9212875}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 1.2368622, y: 2.8945122}
  m_EdgeRadius: 0
```

#### Tornado Event Sender [组件60446691751160785](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:77897>)

```yaml
PolygonCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1472185465350827}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Points:
    m_Paths:
    - - {x: 0, y: -0.5242195}
      - {x: -1.5740967, y: -1.1039467}
      - {x: 0.11312866, y: -3.634944}
      - {x: 1.6335983, y: -1.0760336}
  m_UseDelaunayMesh: 0
```

#### Stun Hurtbox [组件61353891062718048](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:78344>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1841364053301648}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0.042087555, y: -1.294137}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 1.2525101, y: 1.5681572}
  m_EdgeRadius: 0
```

#### Stun Hurtbox [组件114719897623072781](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:78390>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1841364053301648}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 49c386a20fdaa83a59c1a091a909e14c, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  damageDealt: 1
  hazardType: 1
  damageAsset: {fileID: 0}
  damagePropertyFlags: 0
  resetOnEnable: 0
  canClashTink: 0
  forceParry: 0
  noClashFreeze: 0
  noTerrainThunk: 0
  noTerrainRecoil: 0
  noCorpseSpikeStick: 0
  noBounceCooldown: 0
  overrideCollisionSide: 0
  collisionSide: 0
  invertCollisionSide: 0
  HeroDamagedFSM: {fileID: 0}
  AlwaysSendDamaged: 0
  HeroDamagedFSMEvent:
  HeroDamagedFSMBool:
  HeroDamagedFSMGameObject:
  ClashEvents:
    OnClashUp:
      m_PersistentCalls:
        m_Calls: []
    OnClashDown:
      m_PersistentCalls:
        m_Calls: []
    OnClashLeft:
      m_PersistentCalls:
        m_Calls: []
    OnClashRight:
      m_PersistentCalls:
        m_Calls: []
  OnDamagedHero:
    m_PersistentCalls:
      m_Calls: []
```

#### Collectable Item Pickup [组件8414](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:147670>)

```yaml
Rigidbody2D:
  serializedVersion: 5
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3093}
  m_BodyType: 0
  m_Simulated: 1
  m_UseFullKinematicContacts: 0
  m_UseAutoMass: 0
  m_Mass: 1
  m_LinearDamping: 0
  m_AngularDamping: 0.05
  m_GravityScale: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_Interpolate: 0
  m_SleepingMode: 1
  m_CollisionDetection: 1
  m_Constraints: 4
```

#### Trobbio [组件8415](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:147697>)

```yaml
Rigidbody2D:
  serializedVersion: 5
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 2472}
  m_BodyType: 1
  m_Simulated: 1
  m_UseFullKinematicContacts: 0
  m_UseAutoMass: 0
  m_Mass: 1
  m_LinearDamping: 0
  m_AngularDamping: 0.05
  m_GravityScale: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_Interpolate: 0
  m_SleepingMode: 0
  m_CollisionDetection: 1
  m_Constraints: 4
```

#### Damager [组件8608](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:152917>)

```yaml
CircleCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 2044}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_Radius: 2.03
```

#### Damager [组件8610](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:152989>)

```yaml
CircleCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 2043}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_Radius: 2.03
```

#### Damager [组件8617](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:153241>)

```yaml
CircleCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 2041}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_Radius: 2.03
```

#### Damager [组件8618](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:153277>)

```yaml
CircleCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 2054}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_Radius: 2.03
```

#### Damager [组件8619](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:153313>)

```yaml
CircleCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 2052}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_Radius: 2.03
```

#### Damager [组件8621](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:153385>)

```yaml
CircleCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 2051}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_Radius: 2.03
```

#### Damager [组件8626](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:153565>)

```yaml
CircleCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3094}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_Radius: 2.03
```

#### Damager [组件8627](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:153601>)

```yaml
CircleCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3078}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_Radius: 2.03
```

#### Damager [组件8629](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:153673>)

```yaml
CircleCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3076}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_Radius: 2.03
```

#### Damager [组件8630](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:153709>)

```yaml
CircleCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3073}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_Radius: 2.03
```

#### Damager [组件8637](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:153961>)

```yaml
CircleCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3085}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_Radius: 2.03
```

#### Damager [组件8638](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:153997>)

```yaml
CircleCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3084}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_Radius: 2.03
```

#### Damager [组件8640](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:154069>)

```yaml
CircleCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3082}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_Radius: 2.03
```

#### Tornado Damager [组件8669](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:155448>)

```yaml
PolygonCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 2844}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Points:
    m_Paths:
    - - {x: 0, y: -0.5242195}
      - {x: -1.5740967, y: -1.1039467}
      - {x: 0.11312866, y: -3.634944}
      - {x: 1.6335983, y: -1.0760336}
  m_UseDelaunayMesh: 0
```

#### Tornado Event Sender [组件8687](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:156433>)

```yaml
PolygonCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3881}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Points:
    m_Paths:
    - - {x: 0, y: -0.5242195}
      - {x: -1.5740967, y: -1.1039467}
      - {x: 0.11312866, y: -3.634944}
      - {x: 1.6335983, y: -1.0760336}
  m_UseDelaunayMesh: 0
```

#### Damager [组件8691](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:156641>)

```yaml
PolygonCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3570}
  m_Enabled: 0
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Points:
    m_Paths:
    - - {x: 0.24832934, y: 6.011424}
      - {x: 0.035769254, y: 6.340164}
      - {x: -0.19063807, y: 6.0313573}
      - {x: -0.76008445, y: 0.5780865}
      - {x: -0.47320026, y: -0.8297144}
      - {x: 0.58778536, y: -0.80901694}
      - {x: 0.7600844, y: 0.5366913}
  m_UseDelaunayMesh: 0
```

#### Damager [组件8692](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:156695>)

```yaml
PolygonCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3571}
  m_Enabled: 0
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Points:
    m_Paths:
    - - {x: 0.24832934, y: 6.011424}
      - {x: 0.035769254, y: 6.340164}
      - {x: -0.19063807, y: 6.0313573}
      - {x: -0.76008445, y: 0.5780865}
      - {x: -0.47320026, y: -0.8297144}
      - {x: 0.58778536, y: -0.80901694}
      - {x: 0.7600844, y: 0.5366913}
  m_UseDelaunayMesh: 0
```

#### Damager [组件8693](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:156749>)

```yaml
PolygonCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3572}
  m_Enabled: 0
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Points:
    m_Paths:
    - - {x: 0.24832934, y: 6.011424}
      - {x: 0.035769254, y: 6.340164}
      - {x: -0.19063807, y: 6.0313573}
      - {x: -0.76008445, y: 0.5780865}
      - {x: -0.47320026, y: -0.8297144}
      - {x: 0.58778536, y: -0.80901694}
      - {x: 0.7600844, y: 0.5366913}
  m_UseDelaunayMesh: 0
```

#### Damager [组件8694](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:156803>)

```yaml
PolygonCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3573}
  m_Enabled: 0
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Points:
    m_Paths:
    - - {x: 0.24832934, y: 6.011424}
      - {x: 0.035769254, y: 6.340164}
      - {x: -0.19063807, y: 6.0313573}
      - {x: -0.76008445, y: 0.5780865}
      - {x: -0.47320026, y: -0.8297144}
      - {x: 0.58778536, y: -0.80901694}
      - {x: 0.7600844, y: 0.5366913}
  m_UseDelaunayMesh: 0
```

#### Damager [组件8695](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:156857>)

```yaml
PolygonCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3574}
  m_Enabled: 0
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Points:
    m_Paths:
    - - {x: 0.24832934, y: 6.011424}
      - {x: 0.035769254, y: 6.340164}
      - {x: -0.19063807, y: 6.0313573}
      - {x: -0.76008445, y: 0.5780865}
      - {x: -0.47320026, y: -0.8297144}
      - {x: 0.58778536, y: -0.80901694}
      - {x: 0.7600844, y: 0.5366913}
  m_UseDelaunayMesh: 0
```

#### Damager [组件8696](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:156911>)

```yaml
PolygonCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3575}
  m_Enabled: 0
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Points:
    m_Paths:
    - - {x: 0.24832934, y: 6.011424}
      - {x: 0.035769254, y: 6.340164}
      - {x: -0.19063807, y: 6.0313573}
      - {x: -0.76008445, y: 0.5780865}
      - {x: -0.47320026, y: -0.8297144}
      - {x: 0.58778536, y: -0.80901694}
      - {x: 0.7600844, y: 0.5366913}
  m_UseDelaunayMesh: 0
```

#### Damager [组件8697](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:156965>)

```yaml
PolygonCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3576}
  m_Enabled: 0
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Points:
    m_Paths:
    - - {x: 0.24832934, y: 6.011424}
      - {x: 0.035769254, y: 6.340164}
      - {x: -0.19063807, y: 6.0313573}
      - {x: -0.76008445, y: 0.5780865}
      - {x: -0.47320026, y: -0.8297144}
      - {x: 0.58778536, y: -0.80901694}
      - {x: 0.7600844, y: 0.5366913}
  m_UseDelaunayMesh: 0
```

#### Damager [组件8698](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:157019>)

```yaml
PolygonCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3417}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Points:
    m_Paths:
    - - {x: 0.24832934, y: 6.011424}
      - {x: 0.035769254, y: 6.340164}
      - {x: -0.19063807, y: 6.0313573}
      - {x: -0.76008445, y: 0.5780865}
      - {x: -0.47320026, y: -0.8297144}
      - {x: 0.58778536, y: -0.80901694}
      - {x: 0.7600844, y: 0.5366913}
  m_UseDelaunayMesh: 0
```

#### Damager [组件8699](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:157073>)

```yaml
PolygonCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3416}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Points:
    m_Paths:
    - - {x: 0.24832934, y: 6.011424}
      - {x: 0.035769254, y: 6.340164}
      - {x: -0.19063807, y: 6.0313573}
      - {x: -0.76008445, y: 0.5780865}
      - {x: -0.47320026, y: -0.8297144}
      - {x: 0.58778536, y: -0.80901694}
      - {x: 0.7600844, y: 0.5366913}
  m_UseDelaunayMesh: 0
```

#### Damager [组件8700](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:157127>)

```yaml
PolygonCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3415}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Points:
    m_Paths:
    - - {x: 0.24832934, y: 6.011424}
      - {x: 0.035769254, y: 6.340164}
      - {x: -0.19063807, y: 6.0313573}
      - {x: -0.76008445, y: 0.5780865}
      - {x: -0.47320026, y: -0.8297144}
      - {x: 0.58778536, y: -0.80901694}
      - {x: 0.7600844, y: 0.5366913}
  m_UseDelaunayMesh: 0
```

#### Damager [组件8701](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:157181>)

```yaml
PolygonCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3414}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Points:
    m_Paths:
    - - {x: 0.24832934, y: 6.011424}
      - {x: 0.035769254, y: 6.340164}
      - {x: -0.19063807, y: 6.0313573}
      - {x: -0.76008445, y: 0.5780865}
      - {x: -0.47320026, y: -0.8297144}
      - {x: 0.58778536, y: -0.80901694}
      - {x: 0.7600844, y: 0.5366913}
  m_UseDelaunayMesh: 0
```

#### Damager [组件8702](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:157235>)

```yaml
PolygonCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3413}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Points:
    m_Paths:
    - - {x: 0.24832934, y: 6.011424}
      - {x: 0.035769254, y: 6.340164}
      - {x: -0.19063807, y: 6.0313573}
      - {x: -0.76008445, y: 0.5780865}
      - {x: -0.47320026, y: -0.8297144}
      - {x: 0.58778536, y: -0.80901694}
      - {x: 0.7600844, y: 0.5366913}
  m_UseDelaunayMesh: 0
```

#### Damager [组件8703](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:157289>)

```yaml
PolygonCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3411}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Points:
    m_Paths:
    - - {x: 0.24832934, y: 6.011424}
      - {x: 0.035769254, y: 6.340164}
      - {x: -0.19063807, y: 6.0313573}
      - {x: -0.76008445, y: 0.5780865}
      - {x: -0.47320026, y: -0.8297144}
      - {x: 0.58778536, y: -0.80901694}
      - {x: 0.7600844, y: 0.5366913}
  m_UseDelaunayMesh: 0
```

#### Damager [组件8704](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:157343>)

```yaml
PolygonCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3412}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Points:
    m_Paths:
    - - {x: 0.24832934, y: 6.011424}
      - {x: 0.035769254, y: 6.340164}
      - {x: -0.19063807, y: 6.0313573}
      - {x: -0.76008445, y: 0.5780865}
      - {x: -0.47320026, y: -0.8297144}
      - {x: 0.58778536, y: -0.80901694}
      - {x: 0.7600844, y: 0.5366913}
  m_UseDelaunayMesh: 0
```

#### Start Range Meet [组件8714](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:157880>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 46}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0.07742691, y: 3.2941828}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 13.264412, y: 14.693483}
  m_EdgeRadius: 0
```

#### CamLock Intro [组件8717](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:158018>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 74}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 30.55651, y: 24.574478}
  m_EdgeRadius: 0
```

#### Battle Gate (1) [组件8722](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:158248>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 311}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 0
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0.09987062, y: 2.9257107}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 0.8468791, y: 10.719702}
  m_EdgeRadius: 0
```

#### Start Range [组件8727](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:158478>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 475}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 3.2941828}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 24.61, y: 14.693483}
  m_EdgeRadius: 0
```

#### Battle Gate [组件8749](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:159490>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1105}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 0
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0.06176853, y: 2.589706}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 0.77067494, y: 10.047689}
  m_EdgeRadius: 0
```

#### CamLock Boss [组件8759](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:159950>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1390}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 30.55651, y: 24.574478}
  m_EdgeRadius: 0
```

#### Collectable Item Pickup [组件8790](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:161376>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3093}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 6200000, guid: a13fa49895c3e0b4a8bd66c2e90b512c, type: 2}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 0
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0.5, y: 0.5}
    oldSize: {x: 2, y: 2}
    newSize: {x: 1, y: 1}
    adaptiveTilingThreshold: 0.5
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 0.35, y: 0.25}
  m_EdgeRadius: 0
```

#### Hero Detector [组件8907](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:166758>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 2230}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 2, y: 0.5}
  m_EdgeRadius: 0
```

#### Damage Collider [组件8976](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:169932>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 2060}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 0
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0.09514618, y: -1.390789}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 1.2368622, y: 1.8008728}
  m_EdgeRadius: 0
```

#### FakeDeath ExitRange [组件8983](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:170254>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 2579}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0.5142908}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 45, y: 21.96}
  m_EdgeRadius: 0
```

#### Flinch Detector [组件9036](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:172692>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1780}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0.5271344, y: 1.0428123}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 6.7442694, y: 3.0856247}
  m_EdgeRadius: 0
```

#### Trobbio Bump Floor (8) [组件9064](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:173980>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1812}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: -0.0058250427, y: -1.688159}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 1.5149078, y: 2.474947}
  m_EdgeRadius: 0
```

#### Trobbio Bump Floor (2) [组件9066](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:174072>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1809}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: -0.0058250427, y: -1.688159}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 1.5149078, y: 2.474947}
  m_EdgeRadius: 0
```

#### Trobbio Bump Floor (14) [组件9068](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:174164>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1811}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: -0.0058250427, y: -1.688159}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 1.5149078, y: 2.474947}
  m_EdgeRadius: 0
```

#### Trobbio Bump Floor (13) [组件9070](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:174256>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1803}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: -0.0058250427, y: -1.688159}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 1.5149078, y: 2.474947}
  m_EdgeRadius: 0
```

#### Trobbio Bump Floor [组件9073](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:174394>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1806}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: -0.0058250427, y: -2.0384269}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 1.5149078, y: 1.7744112}
  m_EdgeRadius: 0
```

#### Trobbio Bump Floor (4) [组件9074](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:174440>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1805}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: -0.0058250427, y: -1.688159}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 1.5149078, y: 2.474947}
  m_EdgeRadius: 0
```

#### Trobbio Bump Floor (9) [组件9075](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:174486>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1798}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: -0.0058250427, y: -1.688159}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 1.5149078, y: 2.474947}
  m_EdgeRadius: 0
```

#### Trobbio Bump Floor (1) [组件9076](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:174532>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1796}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: -0.0058250427, y: -1.688159}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 1.5149078, y: 2.474947}
  m_EdgeRadius: 0
```

#### Trobbio Bump Floor (5) [组件9077](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:174578>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1797}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: -0.0058250427, y: -1.688159}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 1.5149078, y: 2.474947}
  m_EdgeRadius: 0
```

#### Trobbio Bump Floor (11) [组件9078](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:174624>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1801}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: -0.0058250427, y: -1.688159}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 1.5149078, y: 2.474947}
  m_EdgeRadius: 0
```

#### Trobbio Bump Floor (3) [组件9079](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:174670>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1802}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: -0.0058250427, y: -1.688159}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 1.5149078, y: 2.474947}
  m_EdgeRadius: 0
```

#### Trobbio Bump Floor (15) [组件9080](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:174716>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1800}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: -0.0058250427, y: -1.688159}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 1.5149078, y: 2.474947}
  m_EdgeRadius: 0
```

#### Trobbio Bump Floor (10) [组件9087](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:175038>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1792}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: -0.0058250427, y: -1.688159}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 1.5149078, y: 2.474947}
  m_EdgeRadius: 0
```

#### Trobbio Bump Floor (12) [组件9089](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:175130>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1785}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: -0.0058250427, y: -1.688159}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 1.5149078, y: 2.474947}
  m_EdgeRadius: 0
```

#### Trobbio Bump Floor (6) [组件9092](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:175268>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1782}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: -0.0058250427, y: -1.688159}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 1.5149078, y: 2.474947}
  m_EdgeRadius: 0
```

#### Trobbio Bump Floor (7) [组件9094](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:175360>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1784}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: -0.0058250427, y: -1.688159}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 1.5149078, y: 2.474947}
  m_EdgeRadius: 0
```

#### Wall Collider [组件9136](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:177292>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1689}
  m_Enabled: 0
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 0
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0.079182565, y: -0.051439047}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 0.805503, y: 8.089661}
  m_EdgeRadius: 0
```

#### Wall Collider [组件9138](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:177384>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 1691}
  m_Enabled: 0
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 0
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0.079182565, y: -0.051439047}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 0.805503, y: 8.089661}
  m_EdgeRadius: 0
```

#### FakeDeath Range [组件9139](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:177430>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 2850}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0.5142908}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 35, y: 21.96}
  m_EdgeRadius: 0
```

#### Trobbio [组件9141](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:177522>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 2472}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 0
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0.09514618, y: -1.9212875}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 1.2368622, y: 2.8945122}
  m_EdgeRadius: 0
```

#### Floor Bouncer [组件9180](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:179316>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 2580}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 0
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0.09514618, y: -1.9212875}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 1.2368622, y: 2.8945122}
  m_EdgeRadius: 0
```

#### Stun Hurtbox [组件9184](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:179500>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3250}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0.042087555, y: -1.294137}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 1.2525101, y: 1.5681572}
  m_EdgeRadius: 0
```

#### Terrain Saver [组件9190](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:179776>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3682}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 0
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0.09514618, y: -1.9212875}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 1.2368622, y: 2.8945122}
  m_EdgeRadius: 0
```

#### Evade Range [组件9193](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:179914>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3683}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: -0.9790878}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 14, y: 8.047867}
  m_EdgeRadius: 0
```

#### Audio Boss Tension [组件9194](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:179960>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3387}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: -32.72032, y: -6.1475487}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 57.14626, y: 22.543102}
  m_EdgeRadius: 0
```

#### Evade Tornado Range [组件9196](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:180052>)

```yaml
BoxCollider2D:
  serializedVersion: 3
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3753}
  m_Enabled: 1
  m_Density: 1
  m_Material: {fileID: 0}
  m_IncludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_ExcludeLayers:
    serializedVersion: 2
    m_Bits: 0
  m_LayerOverridePriority: 0
  m_ForceSendLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ForceReceiveLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_ContactCaptureLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_CallbackLayers:
    serializedVersion: 2
    m_Bits: 4294967295
  m_IsTrigger: 1
  m_UsedByEffector: 0
  m_CompositeOperation: 0
  m_CompositeOrder: 0
  m_Offset: {x: 0, y: 0.99629784}
  m_SpriteTilingProperty:
    border: {x: 0, y: 0, z: 0, w: 0}
    pivot: {x: 0, y: 0}
    oldSize: {x: 0, y: 0}
    newSize: {x: 0, y: 0}
    adaptiveTilingThreshold: 0
    drawMode: 0
    adaptiveTiling: 0
  m_AutoTiling: 0
  m_Size: {x: 10, y: 4.0970955}
  m_EdgeRadius: 0
```

#### Trobbio [组件13148](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1645742>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 2472}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 7e0b9799fb0157646caefd91bc67f0a6, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  audioPlayerPrefab: {fileID: 82724804207875695, guid: 99068b2a95bddff419cb6f176648d4e6, type: 2}
  regularInvincibleAudio:
    Clip: {fileID: 0}
    PitchMin: 0.75
    PitchMax: 1.25
    Volume: 1
    vibrationDataAsset: {fileID: 0}
  blockHitPrefab: {fileID: 1709254077376921, guid: e3986d204468fc44ebaf84af5df3fdfa, type: 2}
  strikeNailPrefab: {fileID: 1709254077376921, guid: 64c20baf394ac9a41b03deea82568445, type: 2}
  slashImpactPrefab: {fileID: 1709254077376921, guid: 97c9ba031f06bae4681d3fda13c3f87b, type: 2}
  corpseSplatPrefab: {fileID: 1709254077376921, guid: ee26d04f9efdaa7458f4fcea07e485df, type: 2}
  hp: 700
  damageScaling:
    Level1Mult: 1.4
    Level2Mult: 1
    Level3Mult: 0.9
    Level4Mult: 0.8
    Level5Mult: 0.8
  enemyType: 0
  doNotGiveSilk: 0
  ignoreFlags: 0
  reaperBundles: 0
  effectOrigin: {x: 0, y: -0.2, z: 0}
  ignoreKillAll: 0
  sendDamageTo: {fileID: 0}
  isPartOfSendToTarget: 0
  tagDamageTakerIgnoreColliderState: 0
  takeTagDamageWhileInvincible: 0
  targetPointOverride: {fileID: 0}
  battleScene: {fileID: 0}
  sendHitTo: {fileID: 0}
  sendKilledToObject: {fileID: 0}
  sendKilledToName:
  smallGeoDrops: 0
  mediumGeoDrops: 0
  largeGeoDrops: 0
  largeSmoothGeoDrops: 0
  megaFlingGeo: 0
  shellShardDrops: 0
  flingSilkOrbsDown: 0
  flingSilkOrbsAimObject: {fileID: 0}
  itemDropGroups: []
  _itemDropProbability: 0
  _itemDrops: []
  hasAlternateHitAnimation: 0
  alternateHitAnimation: False
  invincible: 0
  piercable: 0
  invincibleFromDirection: 0
  preventInvincibleEffect: 1
  preventInvincibleShake: 0
  preventInvincibleAttackBlock: 1
  invincibleRecoil: 0
  dontSendTinkToDamager: 0
  hasAlternateInvincibleSound: 0
  alternateInvincibleSound: {fileID: 0}
  immuneToNailAttacks: 0
  immuneToExplosions: 0
  immuneToBeams: 0
  immuneToHunterWeapon: 0
  immuneToCoal: 0
  immuneToTraps: 0
  immuneToWater: 0
  immuneToSpikes: 0
  immuneToLava: 0
  isMossExtractable: 0
  isSwampExtractable: 0
  isBluebloodExtractable: 0
  deathAudioSnapshot: {fileID: 0}
  hasSpecialDeath: 1
  deathReset: 0
  damageOverride: 0
  ignoreAcid: 0
  ignoreWater: 0
  zeroHPEventOverride: {fileID: 0}
  dontDropMeat: 1
  enemySize: 1
  bigEnemyDeath: 0
  preventDeathAfterHero: 1
  ignoreHazards: 0
  invulnerableTime: 0.25
  semiPersistent: 0
  isDead: 0
  ignorePersistence: 0
  tinkTimer: 0
```

#### Damager [组件14849](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1777206>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 2041}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 49c386a20fdaa83a59c1a091a909e14c, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  damageDealt: 2
  hazardType: 1
  damageAsset: {fileID: 0}
  damagePropertyFlags: 0
  resetOnEnable: 0
  canClashTink: 0
  forceParry: 0
  noClashFreeze: 0
  noTerrainThunk: 0
  noTerrainRecoil: 0
  noCorpseSpikeStick: 0
  noBounceCooldown: 0
  overrideCollisionSide: 0
  collisionSide: 0
  invertCollisionSide: 0
  HeroDamagedFSM: {fileID: 0}
  AlwaysSendDamaged: 0
  HeroDamagedFSMEvent:
  HeroDamagedFSMBool:
  HeroDamagedFSMGameObject:
  ClashEvents:
    OnClashUp:
      m_PersistentCalls:
        m_Calls: []
    OnClashDown:
      m_PersistentCalls:
        m_Calls: []
    OnClashLeft:
      m_PersistentCalls:
        m_Calls: []
    OnClashRight:
      m_PersistentCalls:
        m_Calls: []
  OnDamagedHero:
    m_PersistentCalls:
      m_Calls: []
```

#### Damager [组件14851](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1777302>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 2044}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 49c386a20fdaa83a59c1a091a909e14c, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  damageDealt: 2
  hazardType: 1
  damageAsset: {fileID: 0}
  damagePropertyFlags: 0
  resetOnEnable: 0
  canClashTink: 0
  forceParry: 0
  noClashFreeze: 0
  noTerrainThunk: 0
  noTerrainRecoil: 0
  noCorpseSpikeStick: 0
  noBounceCooldown: 0
  overrideCollisionSide: 0
  collisionSide: 0
  invertCollisionSide: 0
  HeroDamagedFSM: {fileID: 0}
  AlwaysSendDamaged: 0
  HeroDamagedFSMEvent:
  HeroDamagedFSMBool:
  HeroDamagedFSMGameObject:
  ClashEvents:
    OnClashUp:
      m_PersistentCalls:
        m_Calls: []
    OnClashDown:
      m_PersistentCalls:
        m_Calls: []
    OnClashLeft:
      m_PersistentCalls:
        m_Calls: []
    OnClashRight:
      m_PersistentCalls:
        m_Calls: []
  OnDamagedHero:
    m_PersistentCalls:
      m_Calls: []
```

#### Damager [组件14852](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1777350>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 2043}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 49c386a20fdaa83a59c1a091a909e14c, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  damageDealt: 2
  hazardType: 1
  damageAsset: {fileID: 0}
  damagePropertyFlags: 0
  resetOnEnable: 0
  canClashTink: 0
  forceParry: 0
  noClashFreeze: 0
  noTerrainThunk: 0
  noTerrainRecoil: 0
  noCorpseSpikeStick: 0
  noBounceCooldown: 0
  overrideCollisionSide: 0
  collisionSide: 0
  invertCollisionSide: 0
  HeroDamagedFSM: {fileID: 0}
  AlwaysSendDamaged: 0
  HeroDamagedFSMEvent:
  HeroDamagedFSMBool:
  HeroDamagedFSMGameObject:
  ClashEvents:
    OnClashUp:
      m_PersistentCalls:
        m_Calls: []
    OnClashDown:
      m_PersistentCalls:
        m_Calls: []
    OnClashLeft:
      m_PersistentCalls:
        m_Calls: []
    OnClashRight:
      m_PersistentCalls:
        m_Calls: []
  OnDamagedHero:
    m_PersistentCalls:
      m_Calls: []
```

#### Damager [组件14855](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1777494>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 2052}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 49c386a20fdaa83a59c1a091a909e14c, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  damageDealt: 2
  hazardType: 1
  damageAsset: {fileID: 0}
  damagePropertyFlags: 0
  resetOnEnable: 0
  canClashTink: 0
  forceParry: 0
  noClashFreeze: 0
  noTerrainThunk: 0
  noTerrainRecoil: 0
  noCorpseSpikeStick: 0
  noBounceCooldown: 0
  overrideCollisionSide: 0
  collisionSide: 0
  invertCollisionSide: 0
  HeroDamagedFSM: {fileID: 0}
  AlwaysSendDamaged: 0
  HeroDamagedFSMEvent:
  HeroDamagedFSMBool:
  HeroDamagedFSMGameObject:
  ClashEvents:
    OnClashUp:
      m_PersistentCalls:
        m_Calls: []
    OnClashDown:
      m_PersistentCalls:
        m_Calls: []
    OnClashLeft:
      m_PersistentCalls:
        m_Calls: []
    OnClashRight:
      m_PersistentCalls:
        m_Calls: []
  OnDamagedHero:
    m_PersistentCalls:
      m_Calls: []
```

#### Damager [组件14856](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1777542>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 2051}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 49c386a20fdaa83a59c1a091a909e14c, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  damageDealt: 2
  hazardType: 1
  damageAsset: {fileID: 0}
  damagePropertyFlags: 0
  resetOnEnable: 0
  canClashTink: 0
  forceParry: 0
  noClashFreeze: 0
  noTerrainThunk: 0
  noTerrainRecoil: 0
  noCorpseSpikeStick: 0
  noBounceCooldown: 0
  overrideCollisionSide: 0
  collisionSide: 0
  invertCollisionSide: 0
  HeroDamagedFSM: {fileID: 0}
  AlwaysSendDamaged: 0
  HeroDamagedFSMEvent:
  HeroDamagedFSMBool:
  HeroDamagedFSMGameObject:
  ClashEvents:
    OnClashUp:
      m_PersistentCalls:
        m_Calls: []
    OnClashDown:
      m_PersistentCalls:
        m_Calls: []
    OnClashLeft:
      m_PersistentCalls:
        m_Calls: []
    OnClashRight:
      m_PersistentCalls:
        m_Calls: []
  OnDamagedHero:
    m_PersistentCalls:
      m_Calls: []
```

#### Damager [组件14861](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1777782>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 2054}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 49c386a20fdaa83a59c1a091a909e14c, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  damageDealt: 2
  hazardType: 1
  damageAsset: {fileID: 0}
  damagePropertyFlags: 0
  resetOnEnable: 0
  canClashTink: 0
  forceParry: 0
  noClashFreeze: 0
  noTerrainThunk: 0
  noTerrainRecoil: 0
  noCorpseSpikeStick: 0
  noBounceCooldown: 0
  overrideCollisionSide: 0
  collisionSide: 0
  invertCollisionSide: 0
  HeroDamagedFSM: {fileID: 0}
  AlwaysSendDamaged: 0
  HeroDamagedFSMEvent:
  HeroDamagedFSMBool:
  HeroDamagedFSMGameObject:
  ClashEvents:
    OnClashUp:
      m_PersistentCalls:
        m_Calls: []
    OnClashDown:
      m_PersistentCalls:
        m_Calls: []
    OnClashLeft:
      m_PersistentCalls:
        m_Calls: []
    OnClashRight:
      m_PersistentCalls:
        m_Calls: []
  OnDamagedHero:
    m_PersistentCalls:
      m_Calls: []
```

#### Damager [组件14865](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1777974>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3073}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 49c386a20fdaa83a59c1a091a909e14c, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  damageDealt: 2
  hazardType: 1
  damageAsset: {fileID: 0}
  damagePropertyFlags: 0
  resetOnEnable: 0
  canClashTink: 0
  forceParry: 0
  noClashFreeze: 0
  noTerrainThunk: 0
  noTerrainRecoil: 0
  noCorpseSpikeStick: 0
  noBounceCooldown: 0
  overrideCollisionSide: 0
  collisionSide: 0
  invertCollisionSide: 0
  HeroDamagedFSM: {fileID: 0}
  AlwaysSendDamaged: 0
  HeroDamagedFSMEvent:
  HeroDamagedFSMBool:
  HeroDamagedFSMGameObject:
  ClashEvents:
    OnClashUp:
      m_PersistentCalls:
        m_Calls: []
    OnClashDown:
      m_PersistentCalls:
        m_Calls: []
    OnClashLeft:
      m_PersistentCalls:
        m_Calls: []
    OnClashRight:
      m_PersistentCalls:
        m_Calls: []
  OnDamagedHero:
    m_PersistentCalls:
      m_Calls: []
```

#### Damager [组件14869](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1778166>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3076}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 49c386a20fdaa83a59c1a091a909e14c, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  damageDealt: 2
  hazardType: 1
  damageAsset: {fileID: 0}
  damagePropertyFlags: 0
  resetOnEnable: 0
  canClashTink: 0
  forceParry: 0
  noClashFreeze: 0
  noTerrainThunk: 0
  noTerrainRecoil: 0
  noCorpseSpikeStick: 0
  noBounceCooldown: 0
  overrideCollisionSide: 0
  collisionSide: 0
  invertCollisionSide: 0
  HeroDamagedFSM: {fileID: 0}
  AlwaysSendDamaged: 0
  HeroDamagedFSMEvent:
  HeroDamagedFSMBool:
  HeroDamagedFSMGameObject:
  ClashEvents:
    OnClashUp:
      m_PersistentCalls:
        m_Calls: []
    OnClashDown:
      m_PersistentCalls:
        m_Calls: []
    OnClashLeft:
      m_PersistentCalls:
        m_Calls: []
    OnClashRight:
      m_PersistentCalls:
        m_Calls: []
  OnDamagedHero:
    m_PersistentCalls:
      m_Calls: []
```

#### Damager [组件14871](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1778262>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3078}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 49c386a20fdaa83a59c1a091a909e14c, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  damageDealt: 2
  hazardType: 1
  damageAsset: {fileID: 0}
  damagePropertyFlags: 0
  resetOnEnable: 0
  canClashTink: 0
  forceParry: 0
  noClashFreeze: 0
  noTerrainThunk: 0
  noTerrainRecoil: 0
  noCorpseSpikeStick: 0
  noBounceCooldown: 0
  overrideCollisionSide: 0
  collisionSide: 0
  invertCollisionSide: 0
  HeroDamagedFSM: {fileID: 0}
  AlwaysSendDamaged: 0
  HeroDamagedFSMEvent:
  HeroDamagedFSMBool:
  HeroDamagedFSMGameObject:
  ClashEvents:
    OnClashUp:
      m_PersistentCalls:
        m_Calls: []
    OnClashDown:
      m_PersistentCalls:
        m_Calls: []
    OnClashLeft:
      m_PersistentCalls:
        m_Calls: []
    OnClashRight:
      m_PersistentCalls:
        m_Calls: []
  OnDamagedHero:
    m_PersistentCalls:
      m_Calls: []
```

#### Damager [组件14875](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1778454>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3082}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 49c386a20fdaa83a59c1a091a909e14c, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  damageDealt: 2
  hazardType: 1
  damageAsset: {fileID: 0}
  damagePropertyFlags: 0
  resetOnEnable: 0
  canClashTink: 0
  forceParry: 0
  noClashFreeze: 0
  noTerrainThunk: 0
  noTerrainRecoil: 0
  noCorpseSpikeStick: 0
  noBounceCooldown: 0
  overrideCollisionSide: 0
  collisionSide: 0
  invertCollisionSide: 0
  HeroDamagedFSM: {fileID: 0}
  AlwaysSendDamaged: 0
  HeroDamagedFSMEvent:
  HeroDamagedFSMBool:
  HeroDamagedFSMGameObject:
  ClashEvents:
    OnClashUp:
      m_PersistentCalls:
        m_Calls: []
    OnClashDown:
      m_PersistentCalls:
        m_Calls: []
    OnClashLeft:
      m_PersistentCalls:
        m_Calls: []
    OnClashRight:
      m_PersistentCalls:
        m_Calls: []
  OnDamagedHero:
    m_PersistentCalls:
      m_Calls: []
```

#### Damager [组件14877](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1778550>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3084}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 49c386a20fdaa83a59c1a091a909e14c, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  damageDealt: 2
  hazardType: 1
  damageAsset: {fileID: 0}
  damagePropertyFlags: 0
  resetOnEnable: 0
  canClashTink: 0
  forceParry: 0
  noClashFreeze: 0
  noTerrainThunk: 0
  noTerrainRecoil: 0
  noCorpseSpikeStick: 0
  noBounceCooldown: 0
  overrideCollisionSide: 0
  collisionSide: 0
  invertCollisionSide: 0
  HeroDamagedFSM: {fileID: 0}
  AlwaysSendDamaged: 0
  HeroDamagedFSMEvent:
  HeroDamagedFSMBool:
  HeroDamagedFSMGameObject:
  ClashEvents:
    OnClashUp:
      m_PersistentCalls:
        m_Calls: []
    OnClashDown:
      m_PersistentCalls:
        m_Calls: []
    OnClashLeft:
      m_PersistentCalls:
        m_Calls: []
    OnClashRight:
      m_PersistentCalls:
        m_Calls: []
  OnDamagedHero:
    m_PersistentCalls:
      m_Calls: []
```

#### Damager [组件14879](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1778646>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3085}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 49c386a20fdaa83a59c1a091a909e14c, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  damageDealt: 2
  hazardType: 1
  damageAsset: {fileID: 0}
  damagePropertyFlags: 0
  resetOnEnable: 0
  canClashTink: 0
  forceParry: 0
  noClashFreeze: 0
  noTerrainThunk: 0
  noTerrainRecoil: 0
  noCorpseSpikeStick: 0
  noBounceCooldown: 0
  overrideCollisionSide: 0
  collisionSide: 0
  invertCollisionSide: 0
  HeroDamagedFSM: {fileID: 0}
  AlwaysSendDamaged: 0
  HeroDamagedFSMEvent:
  HeroDamagedFSMBool:
  HeroDamagedFSMGameObject:
  ClashEvents:
    OnClashUp:
      m_PersistentCalls:
        m_Calls: []
    OnClashDown:
      m_PersistentCalls:
        m_Calls: []
    OnClashLeft:
      m_PersistentCalls:
        m_Calls: []
    OnClashRight:
      m_PersistentCalls:
        m_Calls: []
  OnDamagedHero:
    m_PersistentCalls:
      m_Calls: []
```

#### Damage Collider [组件14882](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1778790>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 2060}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 49c386a20fdaa83a59c1a091a909e14c, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  damageDealt: 1
  hazardType: 1
  damageAsset: {fileID: 0}
  damagePropertyFlags: 0
  resetOnEnable: 0
  canClashTink: 0
  forceParry: 0
  noClashFreeze: 0
  noTerrainThunk: 0
  noTerrainRecoil: 0
  noCorpseSpikeStick: 0
  noBounceCooldown: 0
  overrideCollisionSide: 0
  collisionSide: 0
  invertCollisionSide: 0
  HeroDamagedFSM: {fileID: 0}
  AlwaysSendDamaged: 0
  HeroDamagedFSMEvent:
  HeroDamagedFSMBool:
  HeroDamagedFSMGameObject:
  ClashEvents:
    OnClashUp:
      m_PersistentCalls:
        m_Calls: []
    OnClashDown:
      m_PersistentCalls:
        m_Calls: []
    OnClashLeft:
      m_PersistentCalls:
        m_Calls: []
    OnClashRight:
      m_PersistentCalls:
        m_Calls: []
  OnDamagedHero:
    m_PersistentCalls:
      m_Calls: []
```

#### Damager [组件14883](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1778838>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3094}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 49c386a20fdaa83a59c1a091a909e14c, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  damageDealt: 1
  hazardType: 1
  damageAsset: {fileID: 0}
  damagePropertyFlags: 0
  resetOnEnable: 0
  canClashTink: 0
  forceParry: 0
  noClashFreeze: 0
  noTerrainThunk: 0
  noTerrainRecoil: 0
  noCorpseSpikeStick: 0
  noBounceCooldown: 0
  overrideCollisionSide: 0
  collisionSide: 0
  invertCollisionSide: 0
  HeroDamagedFSM: {fileID: 0}
  AlwaysSendDamaged: 0
  HeroDamagedFSMEvent:
  HeroDamagedFSMBool:
  HeroDamagedFSMGameObject:
  ClashEvents:
    OnClashUp:
      m_PersistentCalls:
        m_Calls: []
    OnClashDown:
      m_PersistentCalls:
        m_Calls: []
    OnClashLeft:
      m_PersistentCalls:
        m_Calls: []
    OnClashRight:
      m_PersistentCalls:
        m_Calls: []
  OnDamagedHero:
    m_PersistentCalls:
      m_Calls: []
```

#### Stun Hurtbox [组件14892](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1779270>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3250}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 49c386a20fdaa83a59c1a091a909e14c, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  damageDealt: 1
  hazardType: 1
  damageAsset: {fileID: 0}
  damagePropertyFlags: 0
  resetOnEnable: 0
  canClashTink: 0
  forceParry: 0
  noClashFreeze: 0
  noTerrainThunk: 0
  noTerrainRecoil: 0
  noCorpseSpikeStick: 0
  noBounceCooldown: 0
  overrideCollisionSide: 0
  collisionSide: 0
  invertCollisionSide: 0
  HeroDamagedFSM: {fileID: 0}
  AlwaysSendDamaged: 0
  HeroDamagedFSMEvent:
  HeroDamagedFSMBool:
  HeroDamagedFSMGameObject:
  ClashEvents:
    OnClashUp:
      m_PersistentCalls:
        m_Calls: []
    OnClashDown:
      m_PersistentCalls:
        m_Calls: []
    OnClashLeft:
      m_PersistentCalls:
        m_Calls: []
    OnClashRight:
      m_PersistentCalls:
        m_Calls: []
  OnDamagedHero:
    m_PersistentCalls:
      m_Calls: []
```

#### Damager [组件14893](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1779318>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3576}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 49c386a20fdaa83a59c1a091a909e14c, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  damageDealt: 2
  hazardType: 1
  damageAsset: {fileID: 0}
  damagePropertyFlags: 0
  resetOnEnable: 0
  canClashTink: 0
  forceParry: 0
  noClashFreeze: 0
  noTerrainThunk: 0
  noTerrainRecoil: 0
  noCorpseSpikeStick: 0
  noBounceCooldown: 0
  overrideCollisionSide: 0
  collisionSide: 0
  invertCollisionSide: 0
  HeroDamagedFSM: {fileID: 0}
  AlwaysSendDamaged: 0
  HeroDamagedFSMEvent:
  HeroDamagedFSMBool:
  HeroDamagedFSMGameObject:
  ClashEvents:
    OnClashUp:
      m_PersistentCalls:
        m_Calls: []
    OnClashDown:
      m_PersistentCalls:
        m_Calls: []
    OnClashLeft:
      m_PersistentCalls:
        m_Calls: []
    OnClashRight:
      m_PersistentCalls:
        m_Calls: []
  OnDamagedHero:
    m_PersistentCalls:
      m_Calls: []
```

#### Damager [组件14894](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1779366>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3572}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 49c386a20fdaa83a59c1a091a909e14c, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  damageDealt: 2
  hazardType: 1
  damageAsset: {fileID: 0}
  damagePropertyFlags: 0
  resetOnEnable: 0
  canClashTink: 0
  forceParry: 0
  noClashFreeze: 0
  noTerrainThunk: 0
  noTerrainRecoil: 0
  noCorpseSpikeStick: 0
  noBounceCooldown: 0
  overrideCollisionSide: 0
  collisionSide: 0
  invertCollisionSide: 0
  HeroDamagedFSM: {fileID: 0}
  AlwaysSendDamaged: 0
  HeroDamagedFSMEvent:
  HeroDamagedFSMBool:
  HeroDamagedFSMGameObject:
  ClashEvents:
    OnClashUp:
      m_PersistentCalls:
        m_Calls: []
    OnClashDown:
      m_PersistentCalls:
        m_Calls: []
    OnClashLeft:
      m_PersistentCalls:
        m_Calls: []
    OnClashRight:
      m_PersistentCalls:
        m_Calls: []
  OnDamagedHero:
    m_PersistentCalls:
      m_Calls: []
```

#### Damager [组件14895](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1779414>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3573}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 49c386a20fdaa83a59c1a091a909e14c, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  damageDealt: 2
  hazardType: 1
  damageAsset: {fileID: 0}
  damagePropertyFlags: 0
  resetOnEnable: 0
  canClashTink: 0
  forceParry: 0
  noClashFreeze: 0
  noTerrainThunk: 0
  noTerrainRecoil: 0
  noCorpseSpikeStick: 0
  noBounceCooldown: 0
  overrideCollisionSide: 0
  collisionSide: 0
  invertCollisionSide: 0
  HeroDamagedFSM: {fileID: 0}
  AlwaysSendDamaged: 0
  HeroDamagedFSMEvent:
  HeroDamagedFSMBool:
  HeroDamagedFSMGameObject:
  ClashEvents:
    OnClashUp:
      m_PersistentCalls:
        m_Calls: []
    OnClashDown:
      m_PersistentCalls:
        m_Calls: []
    OnClashLeft:
      m_PersistentCalls:
        m_Calls: []
    OnClashRight:
      m_PersistentCalls:
        m_Calls: []
  OnDamagedHero:
    m_PersistentCalls:
      m_Calls: []
```

#### Damager [组件14896](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1779462>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3574}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 49c386a20fdaa83a59c1a091a909e14c, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  damageDealt: 2
  hazardType: 1
  damageAsset: {fileID: 0}
  damagePropertyFlags: 0
  resetOnEnable: 0
  canClashTink: 0
  forceParry: 0
  noClashFreeze: 0
  noTerrainThunk: 0
  noTerrainRecoil: 0
  noCorpseSpikeStick: 0
  noBounceCooldown: 0
  overrideCollisionSide: 0
  collisionSide: 0
  invertCollisionSide: 0
  HeroDamagedFSM: {fileID: 0}
  AlwaysSendDamaged: 0
  HeroDamagedFSMEvent:
  HeroDamagedFSMBool:
  HeroDamagedFSMGameObject:
  ClashEvents:
    OnClashUp:
      m_PersistentCalls:
        m_Calls: []
    OnClashDown:
      m_PersistentCalls:
        m_Calls: []
    OnClashLeft:
      m_PersistentCalls:
        m_Calls: []
    OnClashRight:
      m_PersistentCalls:
        m_Calls: []
  OnDamagedHero:
    m_PersistentCalls:
      m_Calls: []
```

#### Damager [组件14897](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1779510>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3575}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 49c386a20fdaa83a59c1a091a909e14c, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  damageDealt: 2
  hazardType: 1
  damageAsset: {fileID: 0}
  damagePropertyFlags: 0
  resetOnEnable: 0
  canClashTink: 0
  forceParry: 0
  noClashFreeze: 0
  noTerrainThunk: 0
  noTerrainRecoil: 0
  noCorpseSpikeStick: 0
  noBounceCooldown: 0
  overrideCollisionSide: 0
  collisionSide: 0
  invertCollisionSide: 0
  HeroDamagedFSM: {fileID: 0}
  AlwaysSendDamaged: 0
  HeroDamagedFSMEvent:
  HeroDamagedFSMBool:
  HeroDamagedFSMGameObject:
  ClashEvents:
    OnClashUp:
      m_PersistentCalls:
        m_Calls: []
    OnClashDown:
      m_PersistentCalls:
        m_Calls: []
    OnClashLeft:
      m_PersistentCalls:
        m_Calls: []
    OnClashRight:
      m_PersistentCalls:
        m_Calls: []
  OnDamagedHero:
    m_PersistentCalls:
      m_Calls: []
```

#### Damager [组件14898](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1779558>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3571}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 49c386a20fdaa83a59c1a091a909e14c, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  damageDealt: 2
  hazardType: 1
  damageAsset: {fileID: 0}
  damagePropertyFlags: 0
  resetOnEnable: 0
  canClashTink: 0
  forceParry: 0
  noClashFreeze: 0
  noTerrainThunk: 0
  noTerrainRecoil: 0
  noCorpseSpikeStick: 0
  noBounceCooldown: 0
  overrideCollisionSide: 0
  collisionSide: 0
  invertCollisionSide: 0
  HeroDamagedFSM: {fileID: 0}
  AlwaysSendDamaged: 0
  HeroDamagedFSMEvent:
  HeroDamagedFSMBool:
  HeroDamagedFSMGameObject:
  ClashEvents:
    OnClashUp:
      m_PersistentCalls:
        m_Calls: []
    OnClashDown:
      m_PersistentCalls:
        m_Calls: []
    OnClashLeft:
      m_PersistentCalls:
        m_Calls: []
    OnClashRight:
      m_PersistentCalls:
        m_Calls: []
  OnDamagedHero:
    m_PersistentCalls:
      m_Calls: []
```

#### Damager [组件14899](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1779606>)

```yaml
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_GameObject: {fileID: 3570}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {fileID: 11500000, guid: 49c386a20fdaa83a59c1a091a909e14c, type: 3}
  m_Name:
  m_EditorClassIdentifier:
  damageDealt: 2
  hazardType: 1
  damageAsset: {fileID: 0}
  damagePropertyFlags: 0
  resetOnEnable: 0
  canClashTink: 0
  forceParry: 0
  noClashFreeze: 0
  noTerrainThunk: 0
  noTerrainRecoil: 0
  noCorpseSpikeStick: 0
  noBounceCooldown: 0
  overrideCollisionSide: 0
  collisionSide: 0
  invertCollisionSide: 0
  HeroDamagedFSM: {fileID: 0}
  AlwaysSendDamaged: 0
  HeroDamagedFSMEvent:
  HeroDamagedFSMBool:
  HeroDamagedFSMGameObject:
  ClashEvents:
    OnClashUp:
      m_PersistentCalls:
        m_Calls: []
    OnClashDown:
      m_PersistentCalls:
        m_Calls: []
    OnClashLeft:
      m_PersistentCalls:
        m_Calls: []
    OnClashRight:
      m_PersistentCalls:
        m_Calls: []
  OnDamagedHero:
    m_PersistentCalls:
      m_Calls: []
```
