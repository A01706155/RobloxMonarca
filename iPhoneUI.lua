-- 2. PhoneUI

-- Author: Manolo Ramírez Pintor
-- Date: 17/04/2023
-- ITESM Campus Qro

-- Este código es un script que se ejecuta localmente en el entorno del jugador, controla
-- las siguientes cosas para crear un sistema completo de simulación de redes inalámbricas
-- después de implementar el módulo SignalModule que regresa una respuesta desde el servidor.

-- Este script controla:
-- 1. Mostrar y ocultar iPhone
-- 2. Cerrar las interfaces abiertas al presionar el botón HOME
-- 3. Actualizar la barra de estado de acuerdo al valor de la señal
-- 4. Que los iconos abran una app 
-- 5. Que Safari sea funcional
-- 6. Que Spotify sea funcional 
-- 7. SignalStrenght y las zonas de redes
-- 2. El menú Wi-Fi de Configuración para seleccionar entre redes
-- 3. El menú Configuración
-- 4. El menú Wi-Fi de configuración

wait(2) -- Esperamos 2 segundos para que el cliente cargue por completo

-- Variable global signalValue
local signalValue = 0
-- Variable global internetSpeed
local internetSpeed = 100

-- Obtenemos al jugador local
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Obtenemos una referencia al screenGUI
local playerGui = player:WaitForChild("PlayerGui")

-- Agarramos el iPhone como tal
local iPhone = playerGui.ScreenGui.iPhone

-- Obtenemos el TweenService
local TweenService = game:GetService("TweenService")

-- Obtenemos el UserInputService
local UserInputService = game:GetService("UserInputService")

-- Apagamos la interfaz del iPhone (de inicio)
iPhone.Visible = false

-- Inicializamos el audio para la app de Spotify
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://13322137195"
sound.Looped = true
sound.Parent = workspace
sound.Volume = 0.35
-- sound:Play()

-- -------------------------------------------------
-- |        CONFIGURACIÓN DE LA SIMULACIÓN DE LAS  |
-- |               REDES INALÁMBRICAS              |
-- -------------------------------------------------

-- Creamos una variable para especificar si estamos dentro de una red MESH
local isMesh = false

-- Creamos una variable para los casos de uso 
-- 0 = Red actual
-- 1 = Red nueva (MESH)
local casoDeUso = 0

-- Metemos el modulo de SignalModule
local SignalModule = require(workspace.SignalModule)

-- Obtenemos el modelo del juegador para luego obtener su rootPart
local char = player.Character or player.CharacterAdded:Wait() -- obtiene el modelo del jugador

-- Definimos los routers del workspace
-- NOTA 1: Router1, el primer rango y Area1
-- NOTA 2: Se pueden reciclar los routers que siguen después del primero
--         haciendo que al cambiar de escenario o de red sólo se modifiquen
--         algunos parámetros o condicionales.

local routers = {
	workspace.Estante_oficina["Router-TP-Link"].Base,
	workspace.Router_1,
	workspace.Router_2,
	workspace.Router_3,
	workspace.Router_4,
	workspace.Router_5
}

-- Definimos el origen del iPhone (rootPart del jugador)
local origen = char:FindFirstChild("Head")

-- Establecemos los rangos máximos del router
local maxRange = {95, 160, 150, 130, 130, 130}

-- Establecemos las áreas de conexiones roaming (MESH no aplica)
local areas = {
	workspace.wifi_areas.area1, 
	workspace.wifi_areas.area2,
	workspace.wifi_areas.area3,	
	workspace.wifi_areas.area4,
	workspace.wifi_areas.area5
}

-- Creamos una variable global para guardar el área actual del jugador
local areaActual = nil

-- Create a global variable to store the reconnecting status
local reconnecting = false

-- La funcion onTouched permite cambiar de red (roaming)
-- NOTA: Hace falta editar para que sea Red MESH
-- NOTA 2: Editar también para ignorar las reconexiones sin 
--         tener la nueva red seleccionada
local function onTouched(area)
	-- Return a function that receives the other part
	return function(otherPart)
		-- Check if the other part is a player
		local player = game.Players:GetPlayerFromCharacter(otherPart.Parent)
		if player then
			-- Print their name and the name of the area
			print(player.Name .. " is inside the area " .. area.Name)
			-- Check if the area is different from the current area
			if area ~= areaActual and casoDeUso == 1 then
				-- Set the reconnecting status to true
				reconnecting = true
				-- Wait for 10 seconds
				wait(3)
				-- Set the reconnecting status to false
				reconnecting = false
			end
			-- Return the area that touches the player
			areaActual = area
		end
	end
end

-- La función updateSignal permite el cambio de señal entre routers mediante
-- los datos de sus posiciones después de que onTouched obtiene información
-- y la actualiza a la variable de areaActual
local function updateSignal()
	while true do
		print("The current area is:", areaActual)
		-- Check if the player is reconnecting or not
		if reconnecting then
			-- Set the signal value to 5
			signalValue = 5
		elseif casoDeUso == 0 then
			signalValue = SignalModule(routers[1], origen, maxRange[1], areas)
		else
			if areaActual == areas[1] then
				-- Call the SignalModule function and save the value in the global variable
				signalValue = SignalModule(routers[2], origen, maxRange[2], areas)
			elseif areaActual == areas[2] then
				-- Call the SignalModule function and save the value in the global variable
				signalValue = SignalModule(routers[3], origen, maxRange[3], areas)
			elseif areaActual == areas[3] then
				-- Call the SignalModule function and save the value in the global variable
				signalValue = SignalModule(routers[4], origen, maxRange[4], areas)
				-- Check if the player is inside an area first
			elseif areaActual == areas[4] then
				-- Call the SignalModule function and save the value in the global variable
				signalValue = SignalModule(routers[5], origen, maxRange[5], areas)
				-- Check if the player is inside an area first
			elseif areaActual == areas[5] then
				-- Call the SignalModule function and save the value in the global variable
				signalValue = SignalModule(routers[6], origen, maxRange[6], areas)
				-- Check if the player is inside an area first
			elseif areaActual then
				print("I'm in an area but I don't know which one help", areaActual)
			else
				print("I'm not inside an area")
			end

		end
		
		print("Señal: ", signalValue)
		-- Wait for one second
		wait(0.5)
	end
end


-- A partir de aquí comienzan secciones de código del iPhone


--[[

------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------

    -----------------------------------------
   | CODIGO PARA MOSTRAR Y OCULTAR EL IPHONE |
    -----------------------------------------
    
    
    
]]--


local iPhoneinitialPosition = UDim2.new(0.699, 0, 1.2, 0)

-- Asignamos la posicion inicial del iPhone
iPhone.Position = iPhoneinitialPosition

-- Define the final position of the iPhone
local iPhonefinalPosition = UDim2.new(0.699, 0, 0.007, 0)

-- Define the tween information, such as duration, easing style and direction
local showiPhoneTween = TweenInfo.new(
	1.2, -- The duration of the animation in seconds
	Enum.EasingStyle.Exponential, -- The easing style of the animation
	Enum.EasingDirection.InOut -- The easing direction of the animation
)

-- Create the tween using the tween information and the final position
local showiPhoneAnim = TweenService:Create(iPhone, showiPhoneTween, {Position = iPhonefinalPosition})

-- Create a tween to hide the iPhone
local hideiPhoneAnim = TweenService:Create(iPhone, showiPhoneTween, {Position = iPhoneinitialPosition})

-- Define a function that shows the iPhone and plays the tween
function showiPhone()
	iPhone.Visible = true
	showiPhoneAnim:Play()
end

-- Define a variable to keep track of whether the iPhone is visible or not
local iPhoneVisible = false

-- Define a function that shows or hides the iPhone and plays or pauses the tween
function toggleiPhone()
	-- If the iPhone is not visible, show it and play the tween
	if not iPhoneVisible then
		-- print("Mostrar")
		showiPhoneAnim:Play()
	else
		-- print("Ocultar")
		hideiPhoneAnim:Play()
	end
	-- Toggle the value of iPhoneVisible
	iPhoneVisible = not iPhoneVisible
end

-- Define a function that detects when the user presses the key "I" and calls toggleiPhone()
function onInputBegan(input)
	-- Check if the input is a keyboard key press
	if input.UserInputType == Enum.UserInputType.Keyboard then
		-- Check if the key pressed is "I"
		if input.KeyCode == Enum.KeyCode.P then
			-- Call toggleiPhone()
			iPhone.Visible = true
			toggleiPhone()
			print("ToggleiPhone llamado")
		end
	end
end

UserInputService.InputBegan:Connect(onInputBegan)

------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------











--[[

------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------

    ----------------------------------------------
   | CÓDIGO PARA EL FUNCIONAMIENTO DE HOME BUTTON |
    ----------------------------------------------
    
    
    
]]--

-- Hacer que el homeButton tenga animacion y funcionalidad
-- 1. Referenciamos al frame donde tenemos el boton
homeButtonFrame = iPhone.HOME_BUTTON
-- 2. Referenciamos al boton real del frame
homeButton = homeButtonFrame.TextButton
-- 3. Definimos el color default del botón HOME
homeButtonDefaultColor = Color3.new(1, 1, 1)

local HButtoninitialPosition = homeButtonFrame.Position

-- Define the final position of the iPhone
local HButtonfinalPosition = homeButtonFrame.Position + UDim2.new(0, 0, -0.02, 0)

-- Define the tween information, such as duration, easing style and direction
local homeButtonTween = TweenInfo.new(
	0.1, -- The duration of the animation in seconds
	Enum.EasingStyle.Circular, -- The easing style of the animation
	Enum.EasingDirection.In, -- The easing direction of the animation
	0, -- The number of times the animation will repeat (-1 means infinite)
	true -- Whether the animation will reverse direction after each repetition
)

-- Definimos el tween del cambio de color del boton
local homeButtonTweenColor = TweenInfo.new(
	0.15, -- The duration of the animation in seconds
	Enum.EasingStyle.Exponential, -- The easing style of the animation
	Enum.EasingDirection.In -- The easing direction of the animation
)

-- Create the tween using the tween information and the final position
local homeButtonAnim = TweenService:Create(homeButtonFrame, homeButtonTween, {Position = HButtonfinalPosition})

-- Creamos la accion que cambia el color del boton HOME a su color default
local homeColorButtonAnim = TweenService:Create(homeButtonFrame, homeButtonTweenColor, {BackgroundColor3 = homeButtonDefaultColor})

-- Definimos cada una de las apps que se pueden abrir a continuacion
local safari = iPhone.Safari
local settingsApp = iPhone.SettingsApp_Scrollable
local spotify = iPhone.Sputify
local home_menu = iPhone.Home_menu
local wiFiSettings = iPhone.WiFi_settings

-- Connect the Activated event of the button to a function that plays the tween
homeButton.Activated:Connect(function(inputObject)
	
	-- Reproducimos la animacion del boton
	homeButtonAnim:Play()
	
	-- Reestablecer el color del boton HOME
	homeColorButtonAnim:Play()
	
	-- Cerramos las apps abiertas
	safari.Visible = false
	settingsApp.Visible = false
	spotify.Visible = false
	wiFiSettings.Visible = false
	
	-- Nos aseguramos de que Home_menu esté abierto
	home_menu.Visible = true
	
end)


------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------








--[[

------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------

    ----------------------------------------------
   | CÓDIGO PARA EL ADMINISTRADOR DE APLICACIONES |
    ----------------------------------------------
    
    
    
]]--

-- En este codigo abrimos las apps del menú del iPhone y hacemos un fade
-- del splash screen de cada app antes de mostrar el contenido.

-- Referenciamos el frame "Splashes" del iPhone
local splashes = iPhone.Splashes
-- Referenciamos cada "Splash screen" y sus objetos
local safari_splash = splashes.Safari
local safari_splash_icon = safari_splash.ImageLabel
local safari_splash_text = safari_splash.TextLabel

local settingsApp_splash = splashes.Settings
local settingsApp_splash_icon = settingsApp_splash.ImageLabel
local settingsApp_splash_text = settingsApp_splash.TextLabel

local spotify_splash = splashes.Spotify
local spotify_splash_icon = spotify_splash.ImageLabel
local spotify_splash_text = spotify_splash.TextLabel

-- Definimos el estado de las propiedades iniciales
splashes.Visible = false
splashes.BackgroundTransparency = 1

safari_splash.Visible = false
safari_splash.BackgroundTransparency = 1
safari_splash_icon.ImageTransparency = 1
safari_splash_text.TextStrokeTransparency = 1
safari_splash_text.TextTransparency = 0.5

settingsApp_splash.Visible = false
settingsApp_splash.BackgroundTransparency = 1
settingsApp_splash_icon.ImageTransparency = 1
settingsApp_splash_text.TextStrokeTransparency = 1
settingsApp_splash_text.TextTransparency = 0.5

spotify_splash.Visible = false
spotify_splash.BackgroundTransparency = 1
spotify_splash_icon.BackgroundTransparency = 1
spotify_splash_icon.ImageTransparency = 1
spotify_splash_text.TextStrokeTransparency = 1
spotify_splash_text.TextTransparency = 0.5

-- Definimos el color del botón HOME gris para las apps como Safari y Configuración
homeButtonGreyColor = Color3.new(0.498039, 0.498039, 0.498039)
-- Definimos la animacion que cambia el color del botón HOME a gris
local greyHomeColorButtonAnim = TweenService:Create(homeButtonFrame, 
													homeButtonTweenColor, 
													{BackgroundColor3 = homeButtonGreyColor}
												   )

-- Creamos un tween para el splash abriendo de cada app, lo reciclamos
local splashOpenCloseTween = TweenInfo.new(
	1, -- The duration of the animation in seconds
	Enum.EasingStyle.Circular, -- The easing style of the animation
	Enum.EasingDirection.In -- The easing direction of the animation
)

-- Creamos las animaciones para cada app:
-- 1. Safari
local safariSplashBackgroundOpen = TweenService:Create(safari_splash, splashOpenCloseTween, {BackgroundTransparency = 0})
local safariSplashBackgroundClose = TweenService:Create(safari_splash, splashOpenCloseTween, {BackgroundTransparency = 1})
local safariSplashIconOpen = TweenService:Create(safari_splash_icon, splashOpenCloseTween, {ImageTransparency = 0})
local safariSplashIconClose = TweenService:Create(safari_splash_icon, splashOpenCloseTween, {ImageTransparency = 1})
local safariSplashTextOpen = TweenService:Create(safari_splash_text, splashOpenCloseTween, {TextStrokeTransparency = 0, TextTransparency = 0})
local safariSplashTextClose = TweenService:Create(safari_splash_text, splashOpenCloseTween, {TextStrokeTransparency = 1, TextTransparency = 1})

-- 2. Settings
local settingsSplashBackgroundOpen = TweenService:Create(settingsApp_splash, splashOpenCloseTween, {BackgroundTransparency = 0})
local settingsSplashBackgroundClose = TweenService:Create(settingsApp_splash, splashOpenCloseTween, {BackgroundTransparency = 1})
local settingsSplashIconOpen = TweenService:Create(settingsApp_splash_icon, splashOpenCloseTween, {ImageTransparency = 0})
local settingsSplashIconClose = TweenService:Create(settingsApp_splash_icon, splashOpenCloseTween, {ImageTransparency = 1})
local settingsSplashTextOpen = TweenService:Create(settingsApp_splash_text, splashOpenCloseTween, {TextStrokeTransparency = 0, TextTransparency = 0})
local settingsSplashTextClose = TweenService:Create(settingsApp_splash_text, splashOpenCloseTween, {TextStrokeTransparency = 1, TextTransparency = 1})

-- 3. Spotify
local spotifySplashBackgroundOpen = TweenService:Create(spotify_splash, splashOpenCloseTween, {BackgroundTransparency = 0})
local spotifySplashBackgroundClose = TweenService:Create(spotify_splash, splashOpenCloseTween, {BackgroundTransparency = 1})
local spotifySplashIconOpen = TweenService:Create(spotify_splash_icon, splashOpenCloseTween, {ImageTransparency = 0})
local spotifySplashIconClose = TweenService:Create(spotify_splash_icon, splashOpenCloseTween, {ImageTransparency = 1})
local spotifySplashTextOpen = TweenService:Create(spotify_splash_text, splashOpenCloseTween, {TextStrokeTransparency = 0, TextTransparency = 0})
local spotifySplashTextClose = TweenService:Create(spotify_splash_text, splashOpenCloseTween, {TextStrokeTransparency = 1, TextTransparency = 1})

-- Ahora, definimos los botones (iconos) que se encuentran en el menú HOME
-- 1. Safari
local safariAppButton = iPhone.Home_menu.Safari.ImageButton
-- 2. Settings
local settingsAppButton = iPhone.Home_menu.Configuracion.ImageButton
-- 3. Spotify
local spotifyAppButton = iPhone.Home_menu.Sputify.ImageButton

-- Creamos las acciones para cada boton (icono) de la app
-- 1. Safari
safariAppButton.Activated:Connect(function(inputObject)
	
	-- Reproducimos el opening del splash
	splashes.Visible = true
	safari_splash.Visible = true
	wait(0.1)
	safariSplashBackgroundOpen:Play()
	safariSplashIconOpen:Play()
	safariSplashTextOpen:Play()
	
	wait(1.5)
	
	-- Abrimos la app
	safari.Visible = true
	-- Cerramos el menu HOME
	home_menu.Visible = false
	
	-- Reproducimos el ending del splash
	safariSplashBackgroundClose:Play()
	safariSplashIconClose:Play()
	safariSplashTextClose:Play()
	greyHomeColorButtonAnim:Play()
	-- Esperamos 1 seg
	wait(1.5)
	-- Cerramos los splashes
	splashes.Visible = false
	safari_splash.Visible = false

end)

-- 2. Settings
settingsAppButton.Activated:Connect(function(inputObject)

	-- Reproducimos el opening del splash
	splashes.Visible = true
	settingsApp_splash.Visible = true
	wait(0.1)
	settingsSplashBackgroundOpen:Play()
	settingsSplashIconOpen:Play()
	settingsSplashTextOpen:Play()

	wait(1.5)

	-- Abrimos la app
	settingsApp.Visible = true
	-- Cerramos el menu HOME
	home_menu.Visible = false

	-- Reproducimos el ending del splash
	settingsSplashBackgroundClose:Play()
	settingsSplashIconClose:Play()
	settingsSplashTextClose:Play()
	greyHomeColorButtonAnim:Play()
	-- Esperamos 1 seg
	wait(1.5)
	-- Cerramos los splashes
	splashes.Visible = false
	settingsApp_splash.Visible = false

end)

-- 3. Spotify
spotifyAppButton.Activated:Connect(function(inputObject)

	-- Reproducimos el opening del splash
	splashes.Visible = true
	spotify_splash.Visible = true
	wait(0.1)
	spotifySplashBackgroundOpen:Play()
	spotifySplashIconOpen:Play()
	spotifySplashTextOpen:Play()

	wait(1.5)

	-- Abrimos la app
	spotify.Visible = true
	-- Cerramos el menu HOME
	home_menu.Visible = false

	-- Reproducimos el ending del splash
	spotifySplashBackgroundClose:Play()
	spotifySplashIconClose:Play()
	spotifySplashTextClose:Play()
	-- Esperamos 1 seg
	wait(1.5)
	-- Cerramos los splashes
	splashes.Visible = false
	spotify_splash.Visible = false

end)

------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------


--[[

------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------

    ---------------------------------------------
   | CÓDIGO PARA EL FUNCIONAMIENTO DEL NAVEGADOR |
    ---------------------------------------------
    
    
    
]]--

-- Referenciamos el boton actualizar para que al hacer click llamemos a una funcion
local webUpdateButton = safari.Top.replay
-- Definimos el tamaño maximo del scrolling frame, default: {1.007, 0},{0.798, 0}
local maxContentSize = UDim2.new(1.007, 0, 0.798, 0)
-- Creamos una función para simular que la página está cargando
function webLoad()
	-- Reseteamos el tamaño del scrolling frame
	safari.WebContent.Size = UDim2.new(1.007, 0, 0, 0)
	
	wait(20 / signalValue) -- Simulacion de latencia
	
	-- Reseteamos la posicion del scrolling frame
	safari.WebContent.CanvasPosition = Vector2.new(0, 0) -- Aquí debes usar Vector2.new en lugar de {}
	-- Usamos una variable para guardar el valor actual de la escala en Y
	local currentScaleY = 0
	-- Usamos un while loop para cambiar el tamaño del scrolling frame en función de la señal y la velocidad de internet
	while currentScaleY < maxContentSize.Y.Scale do -- Usamos el valor máximo como condición de salida
		-- Calculamos el nuevo tamaño de escala en Y usando una fórmula diferente
		local newScaleY = currentScaleY + maxContentSize.Y.Scale * signalValue * internetSpeed / 90000 -- Sumamos un incremento al valor actual
		-- Asignamos el nuevo tamaño al scrolling frame
		safari.WebContent.Size = UDim2.new(1.007, 0, newScaleY, 0)
		-- Actualizamos el valor actual de la escala en Y
		currentScaleY = newScaleY
		-- Esperamos un tiempo fijo
		wait(math.random(0, 5) / signalValue) -- Simulacion de respuesta al servidor

	end

	-- Asignamos el valor máximo al scrolling frame por si acaso
	safari.WebContent.Size = maxContentSize

end

webUpdateButton.Activated:Connect(function(inputObject)
	print("Actualizar entró")

	webLoad()

end)



------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------


--[[

------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------

    ----------------------------------------------
   | CÓDIGO PARA EL FUNCIONAMIENTO DE SPOTIFY APP |
    ----------------------------------------------
    
    
    
]]--

-- Referenciamos el botón play y el botón pausa
playButton = spotify.play_pause.play
pauseButton = spotify.play_pause.pause

-- Referenciamos el current time de la canción
songCurrentTime = spotify.Current_time

-- Desactivamos los botones
playButton.Visible = true
pauseButton.Visible = false

-- Creamos una variable para guardar el tiempo del sonido
local timePosition = 0

local wasPlayedFirst = false

-- Hacemos un conector para el boton de play
playButton.Activated:Connect(function(inputObject)
	print("Play")
	if sound.Loaded and signalValue > 25 then
		sound.TimePosition = timePosition -- Asignamos el tiempo guardado al sonido
		sound:Play()
		playButton.Visible = false -- Cambiamos la visibilidad del botón de play
		pauseButton.Visible = true -- Cambiamos la visibilidad del botón de pausa
		wasPlayedFirst = true
	elseif not sound.Loaded then
		print("El sonido aún está cargando")
	else
		print("Ocurrió un problema, vuelve a intentarlo en unos segundos")
	end
end)

-- Hacemos un conector para el botón de pausa
pauseButton.Activated:Connect(function(inputObject)
	print("Pause")
	if sound.Playing then
		timePosition = sound.TimePosition -- Guardamos el tiempo del sonido en la variable
		sound:Pause()
		pauseButton.Visible = false -- Cambiamos la visibilidad del botón de pausa
		playButton.Visible = true -- Cambiamos la visibilidad del botón de play
		wasPlayedFirst = false
	end	
end)

-- Creamos una función que convierte los segundos en una cadena con el formato MM:SS
local function formatTime(seconds)
	local minutes = math.floor(seconds / 60) -- Obtenemos los minutos enteros
	local remainingSeconds = seconds % 60 -- Obtenemos los segundos restantes
	return string.format("%2d:%02d", minutes, remainingSeconds) -- Devolvemos la cadena con el formato deseado
end


------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------




--[[

------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------

    ------------------------------------------------
   | CÓDIGO PARA EL FUNCIONAMIENTO DE WIFI SETTINGS |
    ------------------------------------------------
    
    
    
]]--

-- Primero referenciamos el boton para ir al menú de WiFi
local wifiMenuBtn = settingsApp.MainWirelessSettings.WiFiSettingsBtn

-- Hacemos un conector para el boton de wifiMenuBtn
wifiMenuBtn.Activated:Connect(function(inputObject)
	-- Ocultamos el GUI de settings app
	settingsApp.Visible = false
	-- Mostramos el GUI de WiFi settings
	wiFiSettings.Visible = true
end)

-- NOTA: EL WIFI OFICINAS SÓLO ESTÁ DISPONIBLE EN OFICINAS (Fakear la red del arris)

-- Definimos el comportamiento de wiFiSettings a contunuación
-- Primero los botones
local setArrisBtn = wiFiSettings.WiFi1.ActivateButton -- ARRIS
local setTabletsBtn = wiFiSettings.WiFi2.ActivateButton -- Tablets
local setEmpleadosBtn = wiFiSettings.WiFi3.ActivateButton -- Empleados
local setOficinasBtn = wiFiSettings.WiFi4.ActivateButton -- Oficinas

-- Referenciamos el estado selected de cada red
local setArrisState = wiFiSettings.WiFi1.Selected -- ARRIS
local setTabletsState = wiFiSettings.WiFi2.Selected -- Tablets
local setEmpleadosState = wiFiSettings.WiFi3.Selected -- Empleados
local setOficinasState = wiFiSettings.WiFi4.Selected -- Oficinas

-- Establecemos los valores default de los selecteds "✓"
setArrisState.Text = "✓"
setTabletsState.Text = ""
setEmpleadosState.Text = ""
setOficinasState.Text = ""

-- Ahora, hacemos conectores para cada botón
-- Conector de Arris
setArrisBtn.Activated:Connect(function(inputObject)
	
	casoDeUso = 0
	
	setArrisState.Text = "✓"
	setTabletsState.Text = ""
	setEmpleadosState.Text = ""
	setOficinasState.Text = ""
	
end)

setTabletsBtn.Activated:Connect(function(inputObject)

	casoDeUso = 1

	setArrisState.Text = ""
	setTabletsState.Text = "✓"
	setEmpleadosState.Text = ""
	setOficinasState.Text = ""

end)

setEmpleadosBtn.Activated:Connect(function(inputObject)

	casoDeUso = 1

	setArrisState.Text = ""
	setTabletsState.Text = ""
	setEmpleadosState.Text = "✓"
	setOficinasState.Text = ""

end)

-- El de Oficinas es un duplicado del Arris básicamente
setOficinasBtn.Activated:Connect(function(inputObject)

	casoDeUso = 0

	setArrisState.Text = ""
	setTabletsState.Text = ""
	setEmpleadosState.Text = ""
	setOficinasState.Text = "✓"

end)




------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------




------------------------------------------------------------------------
---- ESTO ES PARA EL FUNCIONAMIENTO DE ACTUALIZAR DATOS EN TIEMPO REAL--
------------------------------------------------------------------------
------------------------------------------------------------------------

-- Referenciamos la barra de estado del sistema
local statusBar = iPhone.StatusBar
-- Referenciamos la hora del sistema
local systemTime = statusBar.system_time
-- Referenciamos los iconos del nivel de señal del sistema
local signal_4 = statusBar.WiFi_strenght.Signal_wifi_4_bar
local signal_3 = statusBar.WiFi_strenght.Signal_wifi_3_bar
local signal_2 = statusBar.WiFi_strenght.Signal_wifi_2_bar
local signal_1 = statusBar.WiFi_strenght.Signal_wifi_1_bar
local signal_0 = statusBar.WiFi_strenght.Signal_wifi_0_bar
local signal_err = statusBar.WiFi_strenght.Signal_wifi_bad

-- Desactivar todos los iconos de estado
signal_4.Visible = false
signal_3.Visible = false
signal_2.Visible = false
signal_1.Visible = false
signal_0.Visible = false
signal_err.Visible = false


-- Creamos otra función que accede a la variable global cada 5 segundos y actualiza el screenGUI
local function updateGUI()
	while true do
		-- Accedemos al valor de la variable global
		-- print(signalValue)

		-- DEMO:
		-- signalValue = math.random(0, 100)

		-- Actualizamos el screenGUI con el valor de la señal y la hora
		-- 1. Actualizamos la hora
		local currentTime = os.date("%H:%M") -- use %H for hours and %M for minutes
		systemTime.Text = "" .. tostring(currentTime)
		-- 2. POR AHORA ES DEMO - Actualizamos el valor de la señal con condicionales
		if signalValue >= 80 then
			signal_4.Visible = true
			signal_3.Visible = false
			signal_2.Visible = false
			signal_1.Visible = false
			signal_0.Visible = false
			signal_err.Visible = false
		elseif signalValue >= 70 then
			signal_4.Visible = false
			signal_3.Visible = true
			signal_2.Visible = false
			signal_1.Visible = false
			signal_0.Visible = false
			signal_err.Visible = false
		elseif signalValue >= 50 then
			signal_4.Visible = false
			signal_3.Visible = false
			signal_2.Visible = true
			signal_1.Visible = false
			signal_0.Visible = false
			signal_err.Visible = false
		elseif signalValue >= 25 then
			signal_4.Visible = false
			signal_3.Visible = false
			signal_2.Visible = false
			signal_1.Visible = true
			signal_0.Visible = false
			signal_err.Visible = false
		elseif signalValue >= 1 then
			signal_4.Visible = false
			signal_3.Visible = false
			signal_2.Visible = false
			signal_1.Visible = false
			signal_0.Visible = true
			signal_err.Visible = false
		elseif signalValue == 0 then
			signal_4.Visible = false
			signal_3.Visible = false
			signal_2.Visible = false
			signal_1.Visible = false
			signal_0.Visible = false
			signal_err.Visible = true
		else -- Casos exepcionales en donde la variable diga XD
			signal_4.Visible = false
			signal_3.Visible = false
			signal_2.Visible = false
			signal_1.Visible = false
			signal_0.Visible = false
			signal_err.Visible = true
		end

		-- Ejemplo de print:
		-- playerGui.ScreenGui.TextLabel.Text = "Signal: " .. tostring(signalValue)
		
		-- Esperamos 5 segundos
		wait(0.5)
	end
end

local connectionWasLost = false

local function updateSpotifyGUI()
	while true do
		songCurrentTime.Text = "" .. tostring(formatTime(sound.TimePosition))
		wait(0.02)	
	end
end

local function checkSpotifyInternet()
	while true do
		-- Funcion para el comportamiento del internet
		if sound.Playing and signalValue < 25 and connectionWasLost == false then
			connectionWasLost = true
			wait(6)
			if signalValue < 25 then
				timePosition = sound.TimePosition -- Guardamos el tiempo del sonido en la variable
				sound:Pause()
			end
			repeat 
				wait(0.5)
			until signalValue > 25
			wait(1)
			connectionWasLost = false
		end	

		if sound.Playing == false and wasPlayedFirst == true then
			if sound.Loaded and signalValue > 25 then
				sound.TimePosition = timePosition -- Asignamos el tiempo guardado al sonido
				sound:Play()
			elseif not sound.Loaded then
				print("El sonido aún está cargando")
			else
				print("Ocurrió un problema, vuelve a intentarlo en unos segundos")
			end
		end
		
		wait(0.05)
	end
end

-- Código para inicializar hilos que trabajen de forma paralela
wait(1) -- Esperamos un segundo sólo por si las dudas
spawn(updateGUI) -- Doesn't do anything for now
spawn(updateSpotifyGUI)
spawn(checkSpotifyInternet)
spawn(updateSignal)

-- Conecta la función genérica al evento Touched de cada área
for _, area in pairs(areas) do
	area.Touched:Connect(onTouched(area))
end
