function scr_GameEv(arg0)
{
    if (obj_LvlMGMT.ForceEndRound == false)
    {
        switch (arg0)
        {
            case "Activate":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "PegPop":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "FirstPop":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "FirstPopPerk":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                break;
            
            case "PegFullPop":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "HighestPop":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "GainPoints":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "LosePoints":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "8+Pop":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "256+Pop":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "HalfSecond":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                scr_MakeChargeBar(arg0);
                break;
            
            case "1Second":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                scr_MakeChargeBar(arg0);
                break;
            
            case "1andHalfSecond":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                scr_MakeChargeBar(arg0);
                break;
            
            case "2Second":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                scr_MakeChargeBar(arg0);
                break;
            
            case "2andHalfSecond":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                scr_MakeChargeBar(arg0);
                break;
            
            case "3Second":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                scr_MakeChargeBar(arg0);
                break;
            
            case "3andHalfSecond":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                scr_MakeChargeBar(arg0);
                break;
            
            case "4Second":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                scr_MakeChargeBar(arg0);
                break;
            
            case "5Second":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                scr_MakeChargeBar(arg0);
                break;
            
            case "LevelUp":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "GainLife":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "NubbyLaunchPerk":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                scr_MakeChargeBar("HalfSecond");
                scr_MakeChargeBar("1Second");
                scr_MakeChargeBar("1andHalfSecond");
                scr_MakeChargeBar("2Second");
                scr_MakeChargeBar("2andHalfSecond");
                scr_MakeChargeBar("3Second");
                scr_MakeChargeBar("3andHalfSecond");
                scr_MakeChargeBar("4Second");
                scr_MakeChargeBar("5Second");
                
                if (instance_number(obj_ParPeg) > 0)
                {
                    var _Highest = 0;
                    var _StoreHighPeg = -1;
                    
                    for (var i = 0; i < instance_number(obj_ParPeg); i += 1)
                    {
                        var _iTar = instance_find(obj_ParPeg, i);
                        
                        if (instance_exists(_iTar))
                        {
                            if (_iTar.PegDead == false)
                            {
                                if (_iTar.PegNum > _Highest)
                                {
                                    _Highest = _iTar.PegNum;
                                    _StoreHighPeg = _iTar;
                                }
                            }
                        }
                    }
                    
                    if (_Highest != -1)
                        obj_LvlMGMT.Initial_HighPegNum = _Highest;
                }
                
                if (instance_exists(obj_CH7Manager))
                {
                    with (obj_CH7Manager)
                    {
                        alarm_set(0, 90);
                        alarm_set(1, 60);
                    }
                }
                
                var _NubLaunchHelp = instance_create_depth(0, 0, 100, obj_NubbyLaunchHelper);
                
                with (_NubLaunchHelp)
                    alarm_set(0, 2);
                
                break;
            
            case "NubbyLaunchItem":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "NubbyDies":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "PurchaseItem":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "UpgradeItem":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "NubbyBounce":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                var _Odds = irandom_range(1, 20);
                
                if (_Odds == 2)
                    scr_GameEv("NubbyBounceOdds5");
                
                break;
            
            case "NubbyBounce5":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "NubbyBounce10":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "NubbyBounceOdds5":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "HitWall1":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "HitWall2":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "HitWall3":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "HitWall5":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "AnySummoned":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "5Summoned":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "12Summoned":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "20Summoned":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "RankUp":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "SellItem":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "SellMe":
                break;
            
            case "PassGoal":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                var _Odds = choose(0, 1);
                
                if (_Odds == 1)
                    scr_GameEv("PassGoalOdds50");
                
                break;
            
            case "PassGoalOdds50":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "PassGoalOnce":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "Debug":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "2Popped":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "3Popped":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "5Popped":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "8Popped":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "10Popped":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "12Popped":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "15Popped":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "20Popped":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "30Popped":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "EnableItem":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "ItemTrigger":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "PegHalved":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "PegHalve2":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "PegHalve3":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "PegHalve4":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "PegHalve5":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "PegHalve10":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "PegDoubled":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "PegDouble2":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "PegDouble3":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "PegDouble4":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "PegDouble5":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S1Trigger1":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S1Trigger2":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S1Trigger3":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S1Trigger4":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S1Trigger5":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S1Trigger10":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S2Trigger1":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S2Trigger2":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S2Trigger3":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S2Trigger4":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S2Trigger5":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S2Trigger10":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S3Trigger1":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S3Trigger2":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S3Trigger3":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S3Trigger4":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S3Trigger5":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S3Trigger10":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S4Trigger1":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S4Trigger2":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S4Trigger3":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S4Trigger4":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S4Trigger5":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S4Trigger10":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S5Trigger1":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S5Trigger2":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S5Trigger3":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S5Trigger4":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S5Trigger5":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S5Trigger10":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S6Trigger1":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S6Trigger2":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S6Trigger3":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S6Trigger4":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S6Trigger5":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S6Trigger10":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S7Trigger1":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S7Trigger2":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S7Trigger3":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S7Trigger4":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S7Trigger5":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
            
            case "S7Trigger10":
                scr_ItemMetaOrder(arg0);
                scr_PerkMetaOrder(arg0);
                scr_StatusMetaOrder(arg0);
                break;
        }
    }
}
