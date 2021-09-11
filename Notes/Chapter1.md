# Chapter 1: Your first CoreData App

### Intro

- CoreData sử dụng **SQLite Database**
- Data model ~ database schema
Nên ôn lại kiến thức database cơ bản

### Cách lưu object vào CoreData

Để save 1 object dùng CoreData

- Bước 1: Insert new **NSManagedObject** vào ManagedObjectContext
- Bước 2: Commit the changes bằng cách gọi hàm **save**()

### **NSManagedObjectContext**

### Entity

- Tạo trong CoreData **Editor**
- UI trong **Editor** mày bấm vậy thôi, behind the scene là tạo 1 Class (ex: Person, Employee,..)
- Trong relational database, Entity = Table

> Chú ý: nên ôn lại **Relational database**

### Attribute

---

An attribute is a piece of information attached to a particular **Entity**. 
For example, an **Employee** entity could have attributes for the employee’s name, position and salary. In a database, an attribute corresponds to a particular **field** in a **table**.

### NSEntityDescription

```swift
/// Khi mày tạo 1 NSManagedObject mới, thì không biết object này sẽ là thuộc Entity/Class nào
/// Nên có cần có 1 Description để mô tả => dùng NSEntityDescription
/// Ý nghĩa: object này là thuộc Entity Person + context các thứ...
let personEntityDescription = NSEntityDescription.entity(forEntityName: "Person", in: managedContext)!
let newPersonEntity = NSManagedObject(entity: personEntityDescription, insertInto: managedContext)
newPersonEntity.setValue(name, forKeyPath: "name")
```

### Relationship

- **to-one**: quan hệ 1-1
- **to-many**: quan hệ 1-n

A relationship is a link between multiple **entities**. 
In Core Data, relationships between two entities are called **to-one relationships**, while those between one and many entities are called **to-many relationships**. For example, a **Manager** can have a **to-many relationship** with a set of **employees**, whereas an individual Employee will usually have a to-one relationship with his manager.

### Managed Object Model

- XCode có powerful **Data Model Editor**, cho phép mày tạo **ManagedObjectModel
(Data Model Editor ~ NSManagedObjectModel),** ý là tạo Entities các thứ thôi, còn tạo object ManagedObjectModel thì vẫn là auto gen, trừ khi mày tự tạo trong các chương sau.
- 1 **Managed Object Model** = Entities + Attributes + Relationships
- Giống như 1 **Database** của App mày vậy
- An **Entity** is a class definition in CoreData.
- An **Attribute** is a piece of information attached to an **Entity**.
- A **Relationship** is a link between multiple **Entities**.

**NSManagedObject**

- 1 instance của **NSManagedObject** tương đương 1 instance được lưu trong DB
- An **NSManagedObject** is a run-time representation of a **CoreData Entity**. You can read
and write to its attributes using **Key-Value Coding**.
- **NSManagedObject** represents a single object stored in **Core Data**; you must use it to create, edit, save and delete from your Core Data **Persistent Store**.
- As you’ll see shortly, **NSManagedObject** is a shape-shifter. It can take the form of any entity in your Data Model, appropriating whatever **attributes** and **relationships** you defined.

### KVC - Key Value Coding

- The only way Core Data provides to read the value is **key-value coding**, commonly referred to as **KVC**.
- **KVC** is a mechanism in Foundation for accessing an object’s properties
indirectly using **strings**. In this case, KVC makes **NSMangedObject** behave somewhat
like a dictionary at runtime.
- **Key-value coding** is available to all **classes** inheriting from **NSObject**, including
**NSManagedObject**. You can’t access properties using KVC on a Swift object that
doesn’t descend (~inherit) from NSObject.