-- bwing
-- created by blender script
local scale_factor = SCALE_FACTOR or 1
model = ModelData()
model:setName("bwing")
model:setMesh("mesh/bwing.obj")
model:setTexture("mesh/bwing_color.png")
model:setIllumination("mesh/bwing_emit.png")
model:setScale(scale_factor)
model:setRadius(6.9*scale_factor)
model:setCollisionBox(3.8*2*scale_factor, 5.7*2*scale_factor)
