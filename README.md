# Car Dashboard Simulator

<div align="center">
  <img src="dashboard.png" alt="Car Dashboard Interface" width="600">
</div>

## Overview

Car Dashboard Simulator is an interactive AutoHotkey v2 application that demonstrates object-oriented programming principles through a realistic car dashboard interface. The project simulates a modern digital dashboard with speedometer, RPM gauge, fuel level, and temperature monitoring.

Object-oriented programming concept example in AutoHotkey v2.

## Class Definition and Instantiation

The script features two main classes: `Car` and `CarGUI`, showing how to structure code around objects. Notice how the classes are instantiated:

```cpp
CarGUI()  // Creates an instance of the CarGUI class
```

This demonstrates the proper way to create objects in AHK v2 without using the "new" keyword.

## Constructor Method (__New)

The constructor method is special in AHK v2 classes. When you look at the Car class constructor:

```cpp
__New(make, model, maxSpeed) {
    this._make := make
    this._model := model
    this._maxSpeed := maxSpeed
    this._currentSpeed := 0
}
```

This shows how to initialize an object when it's created, accepting parameters and setting up initial state. The constructor runs automatically when you create a new instance.

## Private Properties

The script uses underscores to mark properties as private:

```cpp
_make := ""
_model := ""
_maxSpeed := 0
```

This is a coding convention telling other developers, "Hey, don't access these directly from outside the class." It helps with encapsulation, keeping the object's internal state protected.

## Property Getters and Setters

The script showcases different ways to create property accessors:

```cpp
// Full getter/setter pair
Make {
    get => this._make
    set => this._make := value
}

// Getter/setter with validation
MaxSpeed {
    get => this._maxSpeed
    set => this._maxSpeed := (value > 0) ? value : this._maxSpeed
}

// Read-only property using the fat arrow shorthand
RPM => this._rpm
```

These accessors control how properties are read and changed, letting you add validation or other logic when properties are accessed.

## Methods with Parameters

The `Accelerate` and `Brake` methods show how to create functions within a class that perform actions and return values:

```cpp
Accelerate(increase := 10) {
    // Implementation
    return "Current speed is " this._currentSpeed " mph."
}
```

Notice the default parameter value (`:= 10`), which makes the parameter optional.

## Method Binding

One of the trickier aspects of OOP is maintaining the correct context in callbacks. The script shows how to do this properly:

```cpp
this.brakeBtn.OnEvent("Click", this.Brake.Bind(this))
```

This ensures that when the event fires, the method runs with the correct `this` reference.

## Object Composition

The relationship between the two classes shows composition in action:

```cpp
__New() {
    this.car := Car("Rivian", "R3", 150)
    this.CreateGUI()
}
```

The `CarGUI` class creates and contains a `Car` object, demonstrating how classes can be composed of other classes.

## Event-Driven Programming

The script builds an event-driven interface:

```cpp
this.gui.OnEvent("Close", (*) => this.gui.Hide())
```

This shows how to create responsive systems that react to user actions.

## Timer Callbacks

For recurring operations, the script demonstrates proper timer setup:

```cpp
this.animTimer := ObjBindMethod(this, "AnimateDashboard")
SetTimer(this.animTimer, 50)
```

This creates a timer that calls the `AnimateDashboard` method every 50ms, ensuring the correct object context.

## Requirements

- AutoHotkey v2.1-alpha.16 or newer
- Windows 10/11 recommended for best UI rendering

## Usage

1. Clone the repository
2. Run the script with AutoHotkey v2
3. Use the GAS and BRAKE buttons to control the car
4. Press ESC or click the × to close the dashboard
