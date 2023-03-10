# [HNS] Anti Frag (1.0.1)
https://forums.alliedmods.net/showthread.php?t=340791

### Modify Knife Damage + Cooldown From Stabbing T's

![alt text](https://github.com/oqyh/HNS-Anti-Frag/blob/main/img/Screenshot.PNG.jpg?raw=true)


## .:[ ConVars ]:.
 ```
//## Enable Anti-Frag Plugin
//## 1= Yes
//## 0= No
hns_f_enable_plugin "1"

//==========================================================================================

//## How Would You Like Cooldown Will Be For Attacker (CT)
//## 2= Give Attacker (CT) Cooldown From Stabbing To All T's
//## 1= Give Victim (T) Who Got Stabbed God Mode(Cooldown From Getting Stabbed)
//## 0= No (Disable Cooldown)
hns_f_ct_cooldown "1"

//## (in sec) Cooldown Between Knife Stabs
hns_f_knife_cooldown "5.0"

//## How Much Knife Damage To T's 
//## Default: 50 HP
hns_f_knife_damage "50.0"

//==========================================================================================

//## Enable Transparent After Damage
//## 1= Yes
//## 0= No
hns_f_enable_transparent "1"

//## How Much Transparent After Hit
//## 0= Invisible
//## 120= Transparent
//## 255=None
hns_f_transparent "120"

//## Body Red Code Color Pick Here https://www.rapidtables.com/web/color/RGB_Color.html
hns_f_color_r "255"

//## Body Green Code Color  Pick Here https://www.rapidtables.com/web/color/RGB_Color.html
hns_f_color_g "0"

//## Body Blue Code Color  Pick Here https://www.rapidtables.com/web/color/RGB_Color.html
hns_f_color_b "0"

//==========================================================================================

//## Enable Notification Message Chat After Damage For
//## 3= Both Attacker (CT) And Victim (T)
//## 2= Victim (T)
//## 1= Attacker (CT)
//## 0= No Disable Notify Message
hns_f_notify "1"

//## Do You Like The Notification Message To Be Announced To All Players About Who Got Stabbed+Killed
//## 2= Yes With Hp Left
//## 1= Yes
//## 0= No Disable Announcer
hns_f_notify_annoc "0"
```


## .:[ Change Log ]:.
```
(1.0.1)
-Fix Bug
-Fix God Mode Carry To Next Round After Death/Reconnect
-Fix hns_f_knife_damage now accurate damage modify
-Added hns_f_ct_cooldown change type of cooldown
-Added hns_f_notify Message Chat After Damage
-Added hns_f_notify_annoc Message Announcer To All Players 
-Remove hns_f_enable_notify_ct
-Remove hns_f_enable_notify_t

(1.0.0)
-Initial Release
```

## .:[ Donation ]:.

If this project help you reduce time to develop, you can give me a cup of coffee :)

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://paypal.me/oQYh)
