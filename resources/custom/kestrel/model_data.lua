model = ModelData()
model:setName("kestrel")
model:setMesh("custom/kestrel/kestrel_model.obj")
model:setTexture("custom/kestrel/Kestrel_diffuse.png")
model:setSpecular("custom/kestrel/Kestrel_roughness.png")
model:setIllumination("custom/kestrel/Kestrel_emission.png")
model:setScale(7/2)
model:setRadius(40)

-- Visual positions of the beams/missiletubes (blender: -X, Y, Z)
model:addTubePosition(5.8, -5.06, 0)
model:addTubePosition(5.8, 5.06, 0)
model:addTubePosition(-18.53,  0, 3.1) -- will be dropped at the plane anyway

model:addBeamPosition(17.67, -3.9, 2.88)
model:addBeamPosition(17.67, 3.9, 2.88)

model:addEngineEmitter(-17.25, 10.8, 1.33,  1.0, 0.85, 0.13, 3.0)
model:addEngineEmitter(-17.25, 8.23, 1.33,  1.0, 0.85, 0.13, 3.0)
model:addEngineEmitter(-17.25, 9.57, -1.11,  1.0, 0.85, 0.13, 3.0)

model:addEngineEmitter(-17.25, -10.8, 1.33,  1.0, 0.85, 0.13, 3.0)
model:addEngineEmitter(-17.25, -8.23, 1.33,  1.0, 0.85, 0.13, 3.0)
model:addEngineEmitter(-17.25, -9.57, -1.11,  1.0, 0.85, 0.13, 3.0)
