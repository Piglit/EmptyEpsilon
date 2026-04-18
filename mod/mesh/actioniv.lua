-- actioniv
-- created by blender script
local scale_factor = SCALE_FACTOR or 1
model = ModelData()
model:setName("actioniv")
model:setMesh("mesh/actioniv.obj")
model:setTexture("mesh/actioniv_color.png")
model:setIllumination("mesh/actioniv_emit.png")
model:setScale(scale_factor)
model:setRadius(51.5*scale_factor)
model:setCollisionBox(50.2*2*scale_factor, 11.6*2*scale_factor)
