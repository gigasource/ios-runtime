//
//  JSWeakRefConstructor.h
//  NativeScript
//
//  Created by Yavor Georgiev on 02.10.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#ifndef __NativeScript__JSWeakRefConstructor__
#define __NativeScript__JSWeakRefConstructor__

#include <JavaScriptCore/InternalFunction.h>

namespace NativeScript {
class JSWeakRefPrototype;

class JSWeakRefConstructor : public JSC::InternalFunction {
public:
    typedef JSC::InternalFunction Base;

    DECLARE_INFO;

    static JSC::Strong<JSWeakRefConstructor> create(JSC::VM& vm, JSC::Structure* structure, JSWeakRefPrototype* prototype) {
        JSC::Strong<JSWeakRefConstructor> object(vm, new (NotNull, JSC::allocateCell<JSWeakRefConstructor>(vm.heap)) JSWeakRefConstructor(vm, structure));
        object->finishCreation(vm, prototype);
        return object;
    }

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::InternalFunctionType, StructureFlags), info());
    }

private:
    JSWeakRefConstructor(JSC::VM& vm, JSC::Structure* structure);
    void finishCreation(JSC::VM& vm, JSWeakRefPrototype* prototype);
};
} // namespace NativeScript
#endif /* defined(__NativeScript__JSWeakRefConstructor__) */
