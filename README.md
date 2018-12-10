# FS17_ExtendedAttacher
Extended Attacher Script for Farming-Simulator 2017

## Usage
> Used example: SaphirPlowStar CG-Production

```xml
<extendedAttacher attacher="1">
    <pto pass="true" fallbackPosition="0 0 0" fallbackRotation="0 180 0" />
    <dynamicHoses pass="true" useAdditionalHoses="true" identifier="saphirPlowStarCombi" />
</extendedAttacher>
```
*File: vehicle.xml*

```xml
<specializations>
    <specialization name="extendedAttacher" className="ExtendedAttacher" filename="specializations/extendedAttacher.lua" />
</specializations>
```
```xml
<vehicleTypes>
    <type name="SaphirPlowstar" className="Vehicle" filename="$dataS/scripts/vehicles/Vehicle.lua">
        <specialization name="attacherJoints" />
        <specialization name="lights" />
        <specialization name="workArea" />
        <specialization name="workParticles" />
        <specialization name="speedRotatingParts" />
        <specialization name="attachable" />
        <specialization name="powerConsumer" />
        <specialization name="animatedVehicle" />
        <specialization name="cylindered" />
        <specialization name="cultivator" />
        <specialization name="foldable" />
        <specialization name="washable" />
        <specialization name="mountable" />
        <specialization name="extendedAttacher" />
    </type>
</vehicleTypes>
```
*File: vehicle.xml*
