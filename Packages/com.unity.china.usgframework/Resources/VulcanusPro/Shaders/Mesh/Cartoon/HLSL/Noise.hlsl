float easeIn(float interpolator)
{
	return interpolator * interpolator;
}

float easeOut(float interpolator)
{
	return 1 - easeIn(1 - interpolator);
}

float easeInOut(float interpolator)
{
	float easeInValue = easeIn(interpolator);
	float easeOutValue = easeOut(interpolator);
	return lerp(easeInValue, easeOutValue, interpolator);
}

float rand1dTo1d(float3 value, float mutator = 0.546)
{
	float random = frac(sin(value + mutator) * 143758.5453);
	return random;
}

float rand2dTo1d(float2 value, float2 dotDir = float2(12.9898, 78.233))
{
	float2 smallValue = sin(value);
	float random = dot(smallValue, dotDir);
	random = frac(sin(random) * 143758.5453);
	return random;
}

float2 rand2dTo2d(float2 value)
{
	return float2(
        rand2dTo1d(value, float2(12.989, 78.233)),
        rand2dTo1d(value, float2(39.346, 11.135))
    );
}

float rand3dTo1d(float3 value, float3 dotDir = float3(12.9898, 78.233, 37.719))
{
    //make value smaller to avoid artefacts
	float3 smallValue = sin(value);
    //get scalar value from 3d vector
	float random = dot(smallValue, dotDir);
    //make value more random by making it bigger and then taking teh factional part
	random = frac(sin(random) * 143758.5453);
	return random;
}

float3 rand3dTo3d(float3 value)
{
	return float3(
        rand3dTo1d(value, float3(12.989, 78.233, 37.719)),
        rand3dTo1d(value, float3(39.346, 11.135, 83.155)),
        rand3dTo1d(value, float3(73.156, 52.235, 09.151))
    );
}

float2 modulo(float2 divident, float2 divisor)
{
	float2 positiveDivident = divident % divisor + divisor;
	return positiveDivident % divisor;
}

float3 modulo(float3 divident, float3 divisor)
{
	float3 positiveDivident = divident % divisor + divisor;
	return positiveDivident % divisor;
}

float perlinNoise(float2 value, float2 period)
{
	float2 cellsMimimum = floor(value);
	float2 cellsMaximum = ceil(value);
	
	cellsMimimum = modulo(cellsMimimum, period);
	cellsMaximum = modulo(cellsMaximum, period);
	
	//generate random directions
	float2 lowerLeftDirection = rand2dTo2d(float2(cellsMimimum.x, cellsMimimum.y)) * 2 - 1;
	float2 lowerRightDirection = rand2dTo2d(float2(cellsMaximum.x, cellsMimimum.y)) * 2 - 1;
	float2 upperLeftDirection = rand2dTo2d(float2(cellsMimimum.x, cellsMaximum.y)) * 2 - 1;
	float2 upperRightDirection = rand2dTo2d(float2(cellsMaximum.x, cellsMaximum.y)) * 2 - 1;

	float2 fraction = frac(value);

	//get values of cells based on fraction and cell directions
	float lowerLeftFunctionValue = dot(lowerLeftDirection, fraction - float2(0, 0));
	float lowerRightFunctionValue = dot(lowerRightDirection, fraction - float2(1, 0));
	float upperLeftFunctionValue = dot(upperLeftDirection, fraction - float2(0, 1));
	float upperRightFunctionValue = dot(upperRightDirection, fraction - float2(1, 1));

	float interpolatorX = easeInOut(fraction.x);
	float interpolatorY = easeInOut(fraction.y);

	//interpolate between values
	float lowerCells = lerp(lowerLeftFunctionValue, lowerRightFunctionValue, interpolatorX);
	float upperCells = lerp(upperLeftFunctionValue, upperRightFunctionValue, interpolatorX);

	return lerp(lowerCells, upperCells, interpolatorY);
}

void PerlinNoise_float(float2 Value, float2 Period, float Persistance, float Roughness, float Octaves, out float Output)
{
	float noise = 0;
	float frequency = 1;
	float factor = 1;
	
	for (int i = 0; i < Octaves; i++)
	{
		noise = noise + perlinNoise(Value * frequency + i * 0.72354, Period * frequency) * factor;
		factor *= Persistance;
		frequency *= Roughness;
	}
	
	Output = noise + 0.5;
}

float gradientNoise(float value)
{
	float fraction = frac(value);
	float interpolator = easeInOut(fraction);

	float previousCellInclination = rand1dTo1d(floor(value)) * 2 - 1;
	float previousCellLinePoint = previousCellInclination * fraction;

	float nextCellInclination = rand1dTo1d(ceil(value)) * 2 - 1;
	float nextCellLinePoint = nextCellInclination * (fraction - 1);

	return lerp(previousCellLinePoint, nextCellLinePoint, interpolator);
}

void PolygonGradient_float(float2 UV, float Sides, float Width, float Height, out float Output)
{
	float pi = 3.14159265359;
	float aWidth = Width * cos(pi / Sides); //0.951
	float aHeight = Height * cos(pi / Sides);
	float2 uv = (UV * 2 - 1) / float2(aWidth, aHeight); //1/0.951 = 1.0515247108
	uv.y *= -1;
	float pCoord = atan2(uv.x, uv.y);//-1.557
	float r = 2 * pi / Sides;//0.064
	float distance = cos(floor(0.5 + pCoord / r) * r - pCoord) * length(uv);
	Output = saturate((1 - distance) / fwidth(distance));
}

void VoronoiNoise_float(float3 Value, float3 Period, out float Cell, out float Random, out float Edge)
{
	float3 baseCell = floor(Value);

    //first pass to find the closest cell
	float minDistToCell = 10;
	float3 toClosestCell;
	float3 closestCell;
    [unroll]
	for (int x1 = -1; x1 <= 1; x1++)
	{
        [unroll]
		for (int y1 = -1; y1 <= 1; y1++)
		{
            [unroll]
			for (int z1 = -1; z1 <= 1; z1++)
			{
				float3 cell = baseCell + float3(x1, y1, z1);
				float3 tiledCell = modulo(cell, Period);
				float3 cellPosition = cell + rand3dTo3d(tiledCell);
				float3 toCell = cellPosition - Value;
				float distToCell = length(toCell);
				if (distToCell < minDistToCell)
				{
					minDistToCell = distToCell;
					closestCell = cell;
					toClosestCell = toCell;
				}
			}
		}
	}

    //second pass to find the distance to the closest edge
	float minEdgeDistance = 10;
    [unroll]
	for (int x2 = -1; x2 <= 1; x2++)
	{
        [unroll]
		for (int y2 = -1; y2 <= 1; y2++)
		{
            [unroll]
			for (int z2 = -1; z2 <= 1; z2++)
			{
				float3 cell = baseCell + float3(x2, y2, z2);
				float3 tiledCell = modulo(cell, Period);
				float3 cellPosition = cell + rand3dTo3d(tiledCell);
				float3 toCell = cellPosition - Value;

				float3 diffToClosestCell = abs(closestCell - cell);
				bool isClosestCell = diffToClosestCell.x + diffToClosestCell.y + diffToClosestCell.z < 0.1;
				if (!isClosestCell)
				{
					float3 toCenter = (toClosestCell + toCell) * 0.5;
					float3 cellDifference = normalize(toCell - toClosestCell);
					float edgeDistance = dot(toCenter, cellDifference);
					minEdgeDistance = min(minEdgeDistance, edgeDistance);
				}
			}
		}
	}

	float random = rand3dTo1d(closestCell);
	Cell = minDistToCell;
	Random = random;
	Edge = minEdgeDistance;
}
