-- gr75
-- created by blender script
local scale_factor = SCALE_FACTOR or 1
model = ModelData()
model:setName("gr75")
model:setMesh("mesh/gr75.obj")
model:setTexture("mesh/gr75_color.png")
model:setIllumination("mesh/gr75_emit.png")
model:setScale(scale_factor)
model:setRadius(47.7*scale_factor)
model:setCollisionBox(45.7*2*scale_factor, 13.8*2*scale_factor)
