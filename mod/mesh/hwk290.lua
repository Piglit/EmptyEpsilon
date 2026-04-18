-- hwk290
-- created by blender script
local scale_factor = SCALE_FACTOR or 1
model = ModelData()
model:setName("hwk290")
model:setMesh("mesh/hwk290.obj")
model:setTexture("mesh/hwk290_color.png")
model:setIllumination("mesh/hwk290_emit.png")
model:setScale(scale_factor)
model:setRadius(20.0*scale_factor)
--model:setCollisionBox(17.6*2*scale_factor, 9.5*2*scale_factor)
