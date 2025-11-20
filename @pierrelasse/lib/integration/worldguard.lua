local WorldGuard = importOrNil("com.sk89q.worldguard.WorldGuard")
local BukkitAdapter = importOrNil("com.sk89q.worldedit.bukkit.BukkitAdapter")


local this = {}

if WorldGuard ~= nil then
    ---@cast BukkitAdapter java.class

    this.wg = WorldGuard.getInstance() ---@type java.Object
    this.wgp = this.wg.getPlatform() ---@type java.Object
else
    scripting.warning("pierrelasse/lib/integration/worldguard: not available")
end
this.unavailable = this.wg == nil

---If the specified location is inside the specified region.
---@param location bukkit.Location
---@param regionName string
function this.checkRegion(location, regionName)
    if this.unavailable then return false end

    local regionManager = this.wgp
        .getRegionContainer()
        .get(BukkitAdapter.adapt(location.getWorld()))
    if regionManager == nil then return false end

    ---@type java.Set<{ getId: fun(): string }>
    local regionSet = regionManager.getApplicableRegions(BukkitAdapter.asBlockVector(location))
    for i in forEach(regionSet) do
        if i.getId() == regionName then
            return true
        end
    end

    return false
end

return this
