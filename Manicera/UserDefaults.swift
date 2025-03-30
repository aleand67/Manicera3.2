//
//  UserDefaults.swift
//  Manicera
//
//  Created by Alejandro Andreotti on 3/14/25.
//

import SwiftUI

extension UserDefaults {
    var wasOrangeButtonUsed: Bool{
        get {
            return (UserDefaults.standard.value(forKey: "wasOrangeButtonUsed") as? Bool) ?? false
        }
        set{
            UserDefaults.standard.setValue(newValue, forKey: "wasOrangeButtonUsed")
        }
    }
    
    var wasWhiteButtonUsed: Bool{
        get {
            return (UserDefaults.standard.value(forKey: "wasWhiteButtonUsed") as? Bool) ?? false
        }
        set{
            UserDefaults.standard.setValue(newValue, forKey: "wasWhiteButtonUsed")
        }
    }
    
    var wasOScoreButtonUsed: Bool{
        get {
            return (UserDefaults.standard.value(forKey: "wasOScoreButtonUsed") as? Bool) ?? false
        }
        set{
            UserDefaults.standard.setValue(newValue, forKey: "wasOScoreButtonUsed")
        }
    }
    
    var wasWScoreButtonUsed: Bool{
        get {
            return (UserDefaults.standard.value(forKey: "wasWScoreButtonUsed") as? Bool) ?? false
        }
        set{
            UserDefaults.standard.setValue(newValue, forKey: "wasWScoreButtonUsed")
        }
    }
    
    var wasInningButtonUsed: Bool{
        get {
            return (UserDefaults.standard.value(forKey: "wasInningButtonUsed") as? Bool) ?? false
        }
        set{
            UserDefaults.standard.setValue(newValue, forKey: "wasInningButtonUsed")
        }
    }
    
    var wasSwipingUsed: Bool{
        get {
            return (UserDefaults.standard.value(forKey: "wasSwipingUsed") as? Bool) ?? false
        }
        set{
            UserDefaults.standard.setValue(newValue, forKey: "wasSwipingUsed")
        }
    }
    
    var wasStatsContextMenuUsed: Bool{
        get {
            return (UserDefaults.standard.value(forKey: "wasSwipingUsed") as? Bool) ?? false
        }
        set{
            UserDefaults.standard.setValue(newValue, forKey: "wasSwipingUsed")
        }
    }
}
