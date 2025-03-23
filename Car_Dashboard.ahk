#Requires AutoHotkey v2.1-alpha.16
#SingleInstance Force

/**
 * @description Initialize the Car Dashboard GUI application
 */
CarGUI()

/**
 * @class Car
 * @description Simulates a car with physics properties and controls
 */
class Car {
    _make := ""
    _model := ""
    _maxSpeed := 0
    _currentSpeed := 0
    _rpm := 0
    _fuel := 100
    _temp := 70

    /**
     * @constructor
     * @param {String} make - The manufacturer of the car
     * @param {String} model - The model name of the car
     * @param {Number} maxSpeed - Maximum speed the car can reach in mph
     */
    __New(make, model, maxSpeed) {
        this._make := make
        this._model := model
        this._maxSpeed := maxSpeed
        this._currentSpeed := 0
    }

    /**
     * @method Accelerate
     * @description Increases the car's speed and updates related metrics
     * @param {Number} increase - Amount to increase speed by (default: 10)
     * @returns {String} Status message describing the result
     */
    Accelerate(increase := 10) {
        newSpeed := this._currentSpeed + increase
        if (newSpeed > this._maxSpeed) {
            this._currentSpeed := this._maxSpeed
            return this._make " " this._model " has reached its max speed of " this._maxSpeed " mph!"
        } else {
            this._currentSpeed := newSpeed
            this._rpm := Min(7000, this._currentSpeed * 50)
            this._temp := Min(95, 70 + this._currentSpeed / 5)
            this._fuel := Max(0, this._fuel - 0.2)
            return "Current speed is " this._currentSpeed " mph."
        }
    }

    /**
     * @method Brake
     * @description Decreases the car's speed and updates related metrics
     * @param {Number} decrease - Amount to decrease speed by (default: 10)
     * @returns {String} Status message describing the result
     */
    Brake(decrease := 10) {
        newSpeed := this._currentSpeed - decrease
        if (newSpeed < 0)
            this._currentSpeed := 0
        else
            this._currentSpeed := newSpeed
        
        this._rpm := Min(7000, this._currentSpeed * 50)
        this._temp := Max(70, this._temp - 1)
        
        return "Current speed is now " this._currentSpeed " mph."
    }

    /**
     * @property Make
     * @description Gets/Sets the car's manufacturer
     */
    Make {
        get => this._make
        set => this._make := value
    }
    
    /**
     * @property Model
     * @description Gets/Sets the car's model name
     */
    Model {
        get => this._model
        set => this._model := value
    }
    
    /**
     * @property MaxSpeed
     * @description Gets/Sets the car's maximum speed limit
     */
    MaxSpeed {
        get => this._maxSpeed
        set => this._maxSpeed := (value > 0) ? value : this._maxSpeed
    }
    
    /**
     * @property CurrentSpeed
     * @description Gets/Sets the car's current speed with validation
     */
    CurrentSpeed {
        get => this._currentSpeed
        set {
            if (value >= 0 && value <= this._maxSpeed)
                this._currentSpeed := value
        }
    }
    
    /**
     * @property RPM
     * @description Gets the car's current engine RPM
     */
    RPM => this._rpm
    
    /**
     * @property Fuel
     * @description Gets the car's current fuel level (0-100)
     */
    Fuel => this._fuel
    
    /**
     * @property Temperature
     * @description Gets the car's current engine temperature in Fahrenheit
     */
    Temperature => this._temp
}

/**
 * @class CarGUI
 * @description Creates and manages a car dashboard GUI interface
 */
class CarGUI {
    /**
     * @constructor
     * @description Initialize the car and create the GUI interface
     */
    __New() {
        this.car := Car("Rivian", "R3", 150)
        this.CreateGUI()
    }

    /**
     * @method CreateGUI
     * @description Builds the entire car dashboard interface
     */
    CreateGUI() {
        this.gui := Gui("+Resize -Caption +Border", "Car Dashboard")
        this.gui.BackColor := "171717"
        this.gui.SetFont("s10 cWhite", "Segoe UI")
        this.gui.MarginX := 15
        this.gui.MarginY := 15

        ; Top bar with car name
        this.gui.AddText("xm y10 w350 h25 Center cWhite", this.car.Make " " this.car.Model)
                
        ; Create two sets of speedometer bars on left and right sides
        this.leftSpeedBars := []
        this.rightSpeedBars := []
        
        ; Bar configuration - make them more narrow
        barWidth := 80        ; Narrower bars
        barHeight := 20       ; Fixed height for all bars
        barGap := 4           ; Fixed gap between bars
        leftBarX := 30        ; Left side bars
        rightBarX := 270      ; Right side bars
        
        ; Position and spacing calculations
        totalBars := 5        ; 5 bars on each side
        speedoY := 50        ; Starting position for the top bars
        
        ; Create bars from top to bottom (red on top, green at bottom)
        Loop totalBars {
            ; Calculate Y position moving downward with fixed height and gap
            currentY := speedoY + (barHeight + barGap) * (A_Index - 1)
            
            ; Set the colors in sections
            if (A_Index <= 1)
                barColor := "CC4444"  ; Red (top bar)
            else if (A_Index <= 3)
                barColor := "AAAA44"  ; Yellow (middle bars)
            else
                barColor := "44AA44"  ; Green (bottom bars)
            
            ; Create left side bar
            leftBar := this.gui.AddProgress("x" leftBarX " y" currentY " w" barWidth " h" barHeight " Background222222 c" barColor " Range0-100 Smooth", 0)
            this.leftSpeedBars.Push(leftBar)
            
            ; Create right side bar
            rightBar := this.gui.AddProgress("x" rightBarX " y" currentY " w" barWidth " h" barHeight " Background222222 c" barColor " Range0-100 Smooth", 0)
            this.rightSpeedBars.Push(rightBar)
        }
        
        ; Digital Speedometer - positioned over the bars
        this.digitalSpeed := this.gui.AddText("xm y50 w350 h70 Center BackgroundTrans", "0")
        this.digitalSpeed.SetFont("s48 Bold cWhite", "Segoe UI")
        this.gui.AddText("xm y+0 w350 h20 Center c999999 BackgroundTrans", "mph").SetFont("s12")
        
        ; Calculate position for gauge area below speedometer
        lastBarY := speedoY + (barHeight + barGap) * (totalBars - 1)
        gaugeY := lastBarY + barHeight + 20
        
        ; Additional gauges - RPM, Fuel, Temperature
        this.gui.AddText("xm y" gaugeY " w100 h20", "RPM").SetFont("s9 c999999")
        this.gui.AddText("xm+125 yp w100 h20", "FUEL").SetFont("s9 c999999")
        this.gui.AddText("xm+250 yp w100 h20", "TEMP").SetFont("s9 c999999")
        
        this.rpmGauge := this.gui.AddProgress("xm y+5 w100 h15 Range0-7000 Smooth", 0)
        this.rpmGauge.Opt("Background222222")
        
        this.fuelGauge := this.gui.AddProgress("xm+125 yp w100 h15 Range0-100 Smooth", 100)
        this.fuelGauge.Opt("Background222222 c44AA44")
        
        this.tempGauge := this.gui.AddProgress("xm+250 yp w100 h15 Range0-120 Smooth", 70)
        this.tempGauge.Opt("Background222222 c4444AA")
        
        ; Digital readouts for additional gauges
        this.rpmText := this.gui.AddText("xm y+5 w100 h20 Center", "0")
        this.rpmText.SetFont("s10 cWhite")
        
        this.fuelText := this.gui.AddText("xm+125 yp w100 h20 Center", "100%")
        this.fuelText.SetFont("s10 cWhite")
        
        this.tempText := this.gui.AddText("xm+250 yp w100 h20 Center", "70°F")
        this.tempText.SetFont("s10 cWhite")

        ; Create a container for the pedals with padding
        this.gui.AddText("xm y+10 w350 h120 Center Background222222")
        
        ; Brake pedal (left) - Red
        this.brakeBtn := this.gui.AddButton("xm+40 yp+20 w120 h80", "BRAKE")
        this.brakeBtn.SetFont("s14 Bold cff0000", "Segoe UI")
        this.brakeBtn.Opt("Background222222 cFFFFFF")
        this.brakeBtn.OnEvent("Click", this.Brake.Bind(this))
        
        ; Add border to brake button
        DllCall("user32\SetWindowLong", "Ptr", this.brakeBtn.hwnd, "Int", -16,
            "Int", DllCall("user32\GetWindowLong", "Ptr", this.brakeBtn.hwnd, "Int", -16) | 0x800000)  ; WS_BORDER
        
        ; Gas pedal (right) - Green
        this.accelBtn := this.gui.AddButton("xm+190 yp w120 h80", "GAS")
        this.accelBtn.SetFont("s14 Bold c32e805", "Segoe UI")
        this.accelBtn.Opt("Background222222 cFFFFFF")  ; Green background with white text
        this.accelBtn.OnEvent("Click", this.Accelerate.Bind(this))
        
        ; Add border to gas button
        DllCall("user32\SetWindowLong", "Ptr", this.accelBtn.hwnd, "Int", -16,
            "Int", DllCall("user32\GetWindowLong", "Ptr", this.accelBtn.hwnd, "Int", -16) | 0x800000)  ; WS_BORDER
        
        ; Set button border colors (dark gray)
        DllCall("uxtheme\SetWindowThemeAttribute",
            "Ptr", this.brakeBtn.hwnd,
            "Int", 3,  ; WCA_BORDER_COLOR
            "Int*", 0x404040,  ; Border color (dark gray)
            "Int", 4)
            
        DllCall("uxtheme\SetWindowThemeAttribute",
            "Ptr", this.accelBtn.hwnd,
            "Int", 3,  ; WCA_BORDER_COLOR
            "Int*", 0x404040,  ; Border color (dark gray)
            "Int", 4)
        
        ; Status area
        this.gui.AddText("xm y+20 w350 h2 0x10 Background444444")
        this.statusLabel := this.gui.AddText("xm y+10 w350 h30 Center", "Ready to drive")
        this.statusLabel.SetFont("s10 cB0B0B0")
        
        ; Close button
        this.closeBtn := this.gui.AddButton("xm+310 y10 w30 h30", "×")
        this.closeBtn.SetFont("s16 Bold")
        this.closeBtn.Opt("Background444444 cFFFFFF")
        this.closeBtn.OnEvent("Click", (*) => this.gui.Hide())
        
        ; Set up events
        this.gui.OnEvent("Close", (*) => this.gui.Hide())
        this.gui.OnEvent("Escape", (*) => this.gui.Hide())
        
        ; Add drag functionality for the borderless window
        this.gui.OnEvent("Size", this.OnSize.Bind(this))
        
        ; Make the GUI draggable
        OnMessage(0x0201, this.WM_LBUTTONDOWN.Bind(this))
        
        ; Use a fixed height based on manual calculation
        this.gui.Show("w380 h490")
        
        this.UpdateDisplay()
        
        this.animTimer := ObjBindMethod(this, "AnimateDashboard")
        SetTimer(this.animTimer, 50)
    }
    
    /**
     * @method OnSize
     * @description Handles window resizing events
     * @param {Object} GuiObj - The GUI object
     * @param {Number} MinMax - Window state (1=maximized)
     * @param {Number} Width - New width
     * @param {Number} Height - New height
     */
    OnSize(GuiObj, MinMax, Width, Height) {
        if (MinMax = 1)  ; The window has been maximized
            this.gui.Restore()
    }
    
    /**
     * @method WM_LBUTTONDOWN
     * @description Handles left button down message to make window draggable
     * @param {Number} wParam - The first message parameter
     * @param {Number} lParam - The second message parameter
     * @param {Number} msg - The message ID
     * @param {Number} hwnd - The window handle
     */
    WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
        if (hwnd != this.gui.Hwnd)
            return
        
        PostMessage(0xA1, 2, 0, , "A")  ; Move the window
    }
    
    /**
     * @method UpdateGauges
     * @description Updates all dashboard gauges and displays
     * @param {Number} speed - Current speed to display
     */
    UpdateGauges(speed) {
        ; Update the digital speedometer
        this.digitalSpeed.Text := Round(speed)
        
        ; Calculate normalized speed (0.0 to 1.0)
        normalizedSpeed := speed / this.car.MaxSpeed
        
        ; Fill bars from bottom to top on both sides
        segments := this.leftSpeedBars.Length
        activeSegments := Ceil(normalizedSpeed * segments)
        
        ; Update left side bars
        Loop segments {
            ; Reverse order for activation (from bottom up)
            reversedIndex := segments + 1 - A_Index
            
            if (reversedIndex <= activeSegments) {
                this.leftSpeedBars[A_Index].Value := 100  ; Show bar
            } else {
                this.leftSpeedBars[A_Index].Value := 0    ; Hide bar
            }
        }
        
        ; Update right side bars (identical to left)
        Loop segments {
            ; Reverse order for activation (from bottom up)
            reversedIndex := segments + 1 - A_Index
            
            if (reversedIndex <= activeSegments) {
                this.rightSpeedBars[A_Index].Value := 100  ; Show bar
            } else {
                this.rightSpeedBars[A_Index].Value := 0    ; Hide bar
            }
        }
        
        ; Update additional gauges
        this.rpmGauge.Value := this.car.RPM
        this.fuelGauge.Value := this.car.Fuel
        this.tempGauge.Value := this.car.Temperature
        
        ; Update gauge colors based on values
        rpmColor := this.GetRPMColor(this.car.RPM)
        this.rpmGauge.Opt("c" rpmColor)
        
        fuelColor := this.car.Fuel < 20 ? "CC3333" : "44AA44"
        this.fuelGauge.Opt("c" fuelColor)
        
        tempColor := this.car.Temperature > 90 ? "CC3333" : "4444AA"
        this.tempGauge.Opt("c" tempColor)
        
        ; Update text readouts
        this.rpmText.Text := Round(this.car.RPM)
        this.fuelText.Text := Round(this.car.Fuel) "%"
        this.tempText.Text := Round(this.car.Temperature) "°F"
    }
    
    /**
     * @method GetRPMColor
     * @description Returns a color code based on RPM range
     * @param {Number} rpm - Current RPM value
     * @returns {String} Hex color code
     */
    GetRPMColor(rpm) {
        if (rpm < 2000)
            return "44AA44"  ; Green for low RPM
        else if (rpm < 5000)
            return "AAAA44"  ; Yellow for medium RPM
        else
            return "CC4444"  ; Red for high RPM
    }
    
    /**
     * @method AnimateDashboard
     * @description Smoothly animates dashboard values for visual appeal
     */
    AnimateDashboard() {
        static targetSpeed := 0
        static currentDisplaySpeed := 0
        
        targetSpeed := this.car.CurrentSpeed
        
        if (currentDisplaySpeed < targetSpeed)
            currentDisplaySpeed += Min(2, targetSpeed - currentDisplaySpeed)
        else if (currentDisplaySpeed > targetSpeed)
            currentDisplaySpeed -= Min(2, currentDisplaySpeed - targetSpeed)
        
        if (Abs(currentDisplaySpeed - targetSpeed) > 0.1)
            this.UpdateGauges(currentDisplaySpeed)
    }
    
    /**
     * @method UpdateDisplay
     * @description Updates all dashboard displays with current car values
     */
    UpdateDisplay() {
        this.UpdateGauges(this.car.CurrentSpeed)
    }
    
    /**
     * @method Accelerate
     * @description Handles acceleration button click
     * @param {Any} params - Event parameters (ignored)
     */
    Accelerate(*) {
        statusMsg := this.car.Accelerate()
        this.statusLabel.Text := statusMsg
        this.UpdateDisplay()
    }
    
    /**
     * @method Brake
     * @description Handles brake button click
     * @param {Any} params - Event parameters (ignored)
     */
    Brake(*) {
        statusMsg := this.car.Brake()
        this.statusLabel.Text := statusMsg
        this.UpdateDisplay()
    }
}
