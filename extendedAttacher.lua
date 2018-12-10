--
-- ExtendedAttacher
--
-- @package 	fs17.saphir_plowstar.specializations.extendedAttacher
-- @auhtor 		IceBlade <www.cg-production.com>
-- @copyright 	2018 CG-Production
-- @license    	www.cg-production.com/license/FS_Script_Licence_2018_1.txt
-- @version		1.0.1.0
-- @history		<1.0.0.0> <11.02.2018> creation
--				<1.0.0.1> <05.03.2018> bugfixes
--				<1.0.0.2> <06.03.2018> Changed name to extendedAttacher (before: ptoTransfer), bugfixes
--				<1.0.0.3> <06.03.2018> added specialization 'Attachable' requirement
--				<1.0.0.4> <08.03.2018> added preparations for dynamic hose support
--				<1.0.0.5> <10.03.2018> added dynamic hose support
--				<1.0.1.0> <10.03.2018> added additional dynamic hose support
--

ExtendedAttacher = {};

function ExtendedAttacher.prerequisitesPresent(specializations)
	return SpecializationUtil.hasSpecialization(Attachable, specializations);
end;

function ExtendedAttacher:load()

	self.changeToAdditionalHoses = ExtendedAttacher.changeToAdditionalHoses;

	self.passElements = {};
	self.passElements.attacher = Utils.getNoNil(getXMLInt(self.xmlFile, "vehicle.extendedAttacher#attacher"), false);

	if self.passElements.attacher ~= false then
		-- pto
		self.passElements.passPTO = Utils.getNoNil(getXMLInt(self.xmlFile, "vehicle.extendedAttacher.pto#pass"), false);
		if self.passElements.passPTO then
			self.passElements.ptoFallback = {};
			local x,y,z = Utils.getVectorFromString(getXMLString(self.xmlFile, 'vehicle.extendedAttacher.pto#fallbackPosition'));
			self.passElements.ptoFallback.position = {}
			self.passElements.ptoFallback.position.x = x;
			self.passElements.ptoFallback.position.y = y;
			self.passElements.ptoFallback.position.z = z;
			local x,y,z = Utils.getVectorFromString(getXMLString(self.xmlFile, 'vehicle.extendedAttacher.pto#fallbackRotation'));
			self.passElements.ptoFallback.rotation = {}
			self.passElements.ptoFallback.rotation.x = x;
			self.passElements.ptoFallback.rotation.y = y;
			self.passElements.ptoFallback.rotation.z = z;
		end;

		-- dynamic hoses
		self.passElements.passDynamicHoses = Utils.getNoNil(getXMLInt(self.xmlFile, "vehicle.extendedAttacher.dynamicHoses#pass"), false);
		if self.passElements.passDynamicHoses then
			self.passElements.useAdditionalHoses = Utils.getNoNil(getXMLInt(self.xmlFile, "vehicle.extendedAttacher.dynamicHoses#useAdditionalHoses"), false);
			if self.passElements.useAdditionalHoses then
				self.passElements.additionalHosesIdentifier = getXMLString(self.xmlFile, "vehicle.extendedAttacher.dynamicHoses#identifier");
			end;
		end;
	end;

	if self.passElements.passPTO then
		self.ptoNodeIsUsed = false;
		self.ptoNode = 0;
	end;

	if self.passElements.passDynamicHoses then
		self.dynamicHosesIsUsed = false;
		self.lastVehicleRootNode = 0;
	end;
	self.gameIsLoaded = false;
end;

function ExtendedAttacher:postLoad(savegame)
	if savegame ~= nil and not savegame.resetVehicles then
		local dynamicHosesIsUsed = getXMLBool(savegame.xmlFile, savegame.key .. '#dynamicHosesIsUsed');
		local lastVehicleRootNode = getXMLInt(savegame.xmlFile, savegame.key .. '#lastVehicleRootNode');
		if dynamicHosesIsUsed ~= nil and lastVehicleRootNode ~= nil then
			self.dynamicHosesIsUsed = dynamicHosesIsUsed;
			self.lastVehicleRootNode = lastVehicleRootNode;
			self.gameIsLoaded = true;
		end;
	end;
end;

function ExtendedAttacher:getSaveAttributesAndNodes(nodeIdent)
	local dynamicHosesIsUsed = ('dynamicHosesIsUsed="%s"'):format(self.dynamicHosesIsUsed);
	local lastVehicleRootNode = ('lastVehicleRootNode="%s"'):format(self.lastVehicleRootNode);
	return dynamicHosesIsUsed .. " " .. lastVehicleRootNode;
end;

function ExtendedAttacher:delete()
end;

function ExtendedAttacher:readStream(streamId, connection)
end;

function ExtendedAttacher:writeStream(streamId, connection)
end;

function ExtendedAttacher:mouseEvent(posX, posY, isDown, isUp, button)
end;

function ExtendedAttacher:keyEvent(unicode, sym, modifier, isDown)
end;

function ExtendedAttacher:update(dt)
	if self.isClient then
		-- update pto position
		if self.passElements.passPTO then
			if self.ptoNodeIsUsed then
				local posX, posY, posZ = getWorldTranslation(self.ptoNode);
				local rotX, rotY, rotZ = getWorldRotation(self.ptoNode);
			    setWorldTranslation(self.attacherJoints[self.passElements.attacher]["ptoOutput"].node, posX, posY, posZ);
			    setWorldRotation(self.attacherJoints[self.passElements.attacher]["ptoOutput"].node, rotX, rotY, rotZ);
			end;
		end;
	end;
end;

function ExtendedAttacher:updateTick(dt)
end;

function ExtendedAttacher:draw()
end;

function ExtendedAttacher:onPreAttach()
end;

function ExtendedAttacher:onAttach(vehicle, jointDescIndex)
	if self.isClient then
		if self.passElements.passDynamicHoses then
			if not self.dynamicHosesIsUsed and self.lastVehicleRootNode == 0 then
				if vehicle.dynamicHoseSupport then
					for v, currentVehicle in pairs(g_currentMission.vehicles) do
						if currentVehicle.attacherVehicle ~= nil then				
							if currentVehicle.rootNode ~= self.rootNode then
								if currentVehicle.attacherVehicle.rootNode == self.rootNode then
									self.attacherJoints[self.passElements.attacher].dynamicHoseIndice = vehicle.attacherJoints[jointDescIndex].dynamicHoseIndice;
									self.canWeAttachHose = vehicle.canWeAttachHose;
									self.getDynamicRefSet = vehicle.getDynamicRefSet;
									self.dynamicHoseSupport = true;
									self.activeHoseTypes = vehicle.activeHoseTypes;
									self.hoseRefSets = vehicle.hoseRefSets;
									self.dynamicHosesIsUsed = true;
									self.lastVehicleRootNode = currentVehicle.rootNode;
									currentVehicle:attachDynamicHose(self, self.passElements.attacher, false);
								end;
							end;
						end;
					end;
				end;
			end;
		end;
	end;
	if self.gameIsLoaded then
		if vehicle.dynamicHoseSupport then
			if self.dynamicHosesIsUsed then
				if self.lastVehicleRootNode ~= 0 then
					self.attacherJoints[self.passElements.attacher].dynamicHoseIndice = vehicle.attacherJoints[jointDescIndex].dynamicHoseIndice;
					self.canWeAttachHose = vehicle.canWeAttachHose;
					self.getDynamicRefSet = vehicle.getDynamicRefSet;
					self.dynamicHoseSupport = true;
					self.activeHoseTypes = vehicle.activeHoseTypes;
					self.hoseRefSets = vehicle.hoseRefSets;
				end;
			end;
		end;
	end;
end;

function ExtendedAttacher:onAttached()
	if self.isClient then
		if self.passElements.passPTO then
			if not self.ptoNodeIsUsed then
				for _,implement in pairs(self.attacherVehicle.attachedImplements) do
				    if implement.object ~= nil then
				        if implement.object == self then
				            local jointDesc = self.attacherVehicle.attacherJoints[implement.jointDescIndex];
				            if jointDesc['ptoOutput'] ~= nil then
				            	self.ptoNodeIsUsed = true;
				            	self.ptoNode = jointDesc['ptoOutput'].node;
				            else
				            	self.ptoNodeIsUsed = false;
				            	self.ptoNode = 0;
				            end;
				        end;
				    end;
				end;
			end;
		end;
	end;
end;

function ExtendedAttacher:onDetach()
	if self.isClient then
		-- remove pto node on detach
		if self.passElements.passPTO then
			if self.ptoNodeIsUsed then
				self.ptoNodeIsUsed = false;
				self.ptoNode = 0;
			    setTranslation(self.attacherJoints[self.passElements.attacher]["ptoOutput"].node, self.passElements.ptoFallback.position.x, self.passElements.ptoFallback.position.y, self.passElements.ptoFallback.position.z);
			    setRotation(self.attacherJoints[self.passElements.attacher]["ptoOutput"].node, math.rad(self.passElements.ptoFallback.rotation.x), math.rad(self.passElements.ptoFallback.rotation.y), math.rad(self.passElements.ptoFallback.rotation.z));
			end;
		end;

		-- remove dynamic hose on detach
		if self.passElements.passDynamicHoses then
			if self.dynamicHosesIsUsed then
				for v, vehicle in pairs(g_currentMission.vehicles) do
					if vehicle.rootNode == self.lastVehicleRootNode then
						vehicle:detachDynamicHose(true);
						vehicle:updateMovingToolCouplings(true);
						self.attacherJoints[self.passElements.attacher].dynamicHoseIndice = nil;
						self.canWeAttachHose = nil;
						self.getDynamicRefSet = nil;
						self.dynamicHoseSupport = nil;
						self.activeHoseTypes = nil;
						self.hoseRefSets = nil;
						self.dynamicHosesIsUsed = false;
						self.lastVehicleRootNode = 0;
					end;
				end;
			end;
		end;
	end;
end;
