import XMonad
import XMonad.Util.Ungrab
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Hooks.EwmhDesktops (ewmhFullscreen, ewmh)
import XMonad.Hooks.WindowSwallowing (swallowEventHook)
import XMonad.Hooks.ManageDocks (avoidStruts)
import XMonad.Layout.Tabbed (simpleTabbed)

import System.Exit (exitSuccess)

-- Layout stuff
import XMonad.Layout.MosaicAlt
import qualified Data.Map as M
import XMonad.Layout.Spacing (smartSpacingWithEdge)
import XMonad.Layout.NoBorders (smartBorders)
--import XMonad.Layout.Fulls creen 
--    ( fullscreenFull
--    , fullscreenSupportBorder
--    , fullscreenManageHook
--    , fullscreenEventHook)

import qualified XMonad.StackSet as W

-- XMobar
-- import XMonad.Hooks.DynamicLog
-- import XMonad.Hooks.StatusBar
-- import XMonad.Hooks.StatusBar.PP

import XMonad.Layout.ThreeColumns

myTerminal = "urxvt"

myLayout = --fullscreenFull $ 
    avoidStruts $
    smartBorders $ smartSpacingWithEdge 3 $ 
    leftMaster ||| topMaster ||| Full ||| MosaicAlt M.empty ||| simpleTabbed
  where
    topMaster = Mirror leftMaster
    leftMaster = Tall nmaster delta ratio
    nmaster = 1 -- default number of windows in master pane
    ratio = 3/5 -- proportion of screen occupied by master pane 
    delta = 3/100 -- Percent of screen to increment by when resizing panes

main :: IO ()
main = xmonad $ ewmhFullscreen $ ewmh $ myConfig

myConfig = def
    { terminal = myTerminal
    , modMask = mod1Mask -- alt
    , layoutHook = myLayout
    , borderWidth = 3
    , normalBorderColor = "#123456"
    , focusedBorderColor = "#abcdef"
    -- , manageHook = fullscreenManageHook
    -- , handleEventHook = swallowEventHook (return True) (return True)
    -- swallows too many things!
    } 
    `additionalKeysP` 
    [ ("M-d", spawn "rofi -show drun")
    , ("M-<Return>", spawn myTerminal)
    , ("M-m", windows W.focusMaster)
    , ("M-S-m", windows W.swapMaster)
    , ("M-S-q", kill)
    , ("M-S-e", io exitSuccess)
    -- , ("M-S-r", )
    ]
