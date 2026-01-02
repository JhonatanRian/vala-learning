class SuperClass : GLib.Object {
    public virtual void method_1() {
        stdout.printf("SuperClass.method_1()\n");
    }
}

class SubClass : SuperClass {
    public override void method_1() {
        stdout.printf("SubClass.method_1()\n");
    }
}

public static void main() {
    SuperClass obj1 = new SuperClass();
    SuperClass obj2 = new SubClass();

    obj1.method_1(); // Calls SuperClass.method_1()
    obj2.method_1(); // Calls SubClass.method_1() due to polymorphism
}
