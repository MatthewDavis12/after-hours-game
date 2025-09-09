--!strict

--// Animations
--  
--   Animation object for client character animations. This is primarily for
--   having a single place for managing animations.

--// Animations
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local animationsFile: Folder = ReplicatedStorage:WaitForChild("Animations") :: Folder

--// AnimationClass type defined
type T_AnimationClass = {
    __index:  T_AnimationClass,
    --// Creates a new AnimationsObject   
    new:      (char: Model) -> AnimationsObject,
    --// Stop animations dynamically based on rig type
    Stop:     (self: T_AnimationsMeta, fadeTime: number?) -> (),
    --// GetCount fetches the animation count based on a regex string.
    GetCount: (self: T_AnimationsMeta, matchStr: string) -> number,
    --// Play animations dynamically based on the rig type
    Play:     (self: T_AnimationsMeta, animation: string, ...number?) -> AnimationTrack?,
}

--// AnimationObject type defined
type T_AnimationObject = {
    --// Rig type is fetched from the Humanoid.RigType.Name property. Used to
    --   calculate which animation to run based on it's version.
    rigType:        string,
    --// AnimeCache is used to store all the animations loaded from the 
    --   game/ReplicatedStorage/Animations folder.
    animeCache:     {[string]: {[string]: AnimationTrack}},
    --// CurrentPlaying tracks the currently playing animation to easily stop
    --   animations. This option could be nil
    currentPlaying: AnimationTrack?,
    --// PlayingName helper field for lookups when controlling the animations
    playingName:    string?
}

--// AnimationObject Meta type defined
--   This sets the metatable for the T_AnimationObject type and T_AnimationClass type.
--   In return, we get a new table with the metatable setup which we can define as a new type.
type T_AnimationsMeta = typeof(setmetatable(
    {} :: T_AnimationObject, 
    {} :: T_AnimationClass
))

--// Public facing types
export type AnimationsObject = T_AnimationsMeta

--// Animation Object
local Animations: T_AnimationClass = {} :: T_AnimationClass
Animations.__index = Animations

--// Builds a new animation object
function Animations.new(char: Model): AnimationsObject 
    local hum: Humanoid = char:WaitForChild("Humanoid") :: Humanoid
    local animator: Animator = hum:WaitForChild("Animator") :: Animator

    local self: AnimationsObject = setmetatable({
        animeCache = {},
        rigType = hum.RigType.Name
    }, Animations)

    --// Build the anime cache
    for _, rigType: Instance in pairs(animationsFile:GetChildren()) do
        if not rigType:IsA("Folder") then
            continue
        end

        self.animeCache[rigType.Name] = {} 
        for _, animation:Instance in pairs(rigType:GetChildren()) do
            if not animation:IsA("Animation") then
                continue
            end

            self.animeCache[rigType.Name][animation.Name] = animator:LoadAnimation(animation) 
        end
    end

    return self
end

--// Play method implementation
function Animations:Play(animation: string, ...: number?): AnimationTrack?
    print(animation)
    local animationData = self.animeCache[self.rigType]
    if not animationData then
        return
    end

    local animationTrack: AnimationTrack? = animationData[animation]
    if not animationTrack then
        return
    end

    local fade: number?, weight: number?, speed: number? = ...
    self.playingName = animation
    self.currentPlaying = animationTrack
    animationTrack:Play(fade or 0.1, weight or 1, speed or 1)
    return animationTrack
end

--// Stop method implementation
function Animations:Stop(fadeTime: number?)
    if not self.currentPlaying then
        return
    end

    self.currentPlaying:Stop(fadeTime or 0.1)
    self.playingName = nil
    self.currentPlaying = nil
end

--// GetCount method implementation
function Animations:GetCount(matchStr: string): number
    local matchCount: number = 0
    local animationData = self.animeCache[self.rigType]
    if not animationData then
        return matchCount
    end

    for trackName: string, track: AnimationTrack in pairs(animationData) do
        if not trackName:match(matchStr) then
            continue
        end
        matchCount += 1
    end

    return matchCount
end

return Animations