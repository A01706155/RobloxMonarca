-- 1. SignalModule

-- Author: Manolo Ramírez Pintor
-- Date: 17/04/2023
-- ITESM Campus Qro

-- Este código obtiene partes del workspace de roblox, crea raycasts que atraviesan paredes
-- y devuelve una intensidad de señal inalámbrica en porcentaje menos lo que fue atravesado
-- en el transcurso de la creación y cálculo de la señal inalámbrica. 

-- La función da returns según se necesita y dependiendo de algunas condiciones específicas.

local function getSignal(part1, part2, maxRange, areas)

	-- Creamos una función para hacer el raycast y dibujar el rayo
	local function castRay(origin, direction)
		-- Creamos un objeto Ray con la posición y dirección del rayo
		local ray = Ray.new(origin, direction)

		-- Creamos un objeto RaycastParams para filtrar las partes
		local raycastParams = RaycastParams.new()
		local elems = {part1, part2}
		-- Recorre los elementos de la tabla2
		for _, elemento in pairs(areas) do
			-- Inserta el elemento en la tabla1
			table.insert(elems, elemento)
		end
		
		-- Lista blanca de las partes del jugador
		-- Get the Players service
		local Players = game:GetService("Players")

		-- Get a table of all players
		local allPlayers = Players:GetPlayers()

		-- Loop through each player
		for _, player in pairs(allPlayers) do
			-- Get their character
			local character = player.Character

			-- Check if the character exists
			if character then
				-- Loop through each part in the character
				for _, part in pairs(character:GetChildren()) do
					-- Check if the part is a BasePart
					if part:IsA("BasePart") then
						-- Add the part to the elems table
						table.insert(elems, part)
					end
				end
			end
		end

		
		raycastParams.FilterDescendantsInstances = {elems} -- Solo queremos que el rayo atraviese estas dos partes
		


		-- Usamos el método Workspace:Raycast para obtener el resultado del rayo
		local result = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
		
		-- print("me atore?")
		wait(0.001) -- Para evitar crasheos

		-- Devolvemos el resultado del raycast
		return result
	end

	-- Obtenemos la direccion de las partes
	local direction = part2.Position - part1.Position

	-- Obtenemos la distancia entre las partes
	local distance = direction.Magnitude

	-- Verificamos si la distancia es menor o igual al rango máximo
	if distance <= maxRange then

		-- Inicializamos el origen del rayo con la posición de la parte 1
		local origin = part1.Position

		-- Inicializamos una variable para guardar el resultado del raycast
		local result

		-- Inicializamos una variable para contar el número de partes que el rayo atraviesa
		local partCount = 0

		-- Creamos un bucle que se repita hasta que el resultado sea nil o el rayo llegue al destino final
		repeat
			-- Llamamos a la función castRay con el origen y la dirección del rayo
			result = castRay(origin, direction)

			-- Si el resultado no es nil
			if result then
				-- Actualizamos el origen del rayo con la posición del impacto
				origin = result.Position

				-- Incrementamos el contador de partes en 1
				partCount = partCount + 1
			end

		until result == nil or origin == part2.Position

		-- DEBUG:
		-- Imprimimos el número de partes que el rayo atravesó al output
		-- print("Part count: ", partCount)

		-- Calculamos la fuerza del señal usando una fórmula inversa proporcional a la distancia y le restamos 0.1 por el número de partes
		local signalStrength = ((maxRange - distance) / maxRange) - (partCount * 0.1)

		-- Si la señal es debajo de 5% lo consideramos señal perdida
		if signalStrength < 0.05 then
			return "Signal lost"
		else
			-- Imprimimos la fuerza del señal al output en porcentaje
			return signalStrength*100
		end

	else
		-- Imprimimos que no hay señal al output
		return "Out of range, signal lost"
	end

	-- wait(0.5)

end

return getSignal
