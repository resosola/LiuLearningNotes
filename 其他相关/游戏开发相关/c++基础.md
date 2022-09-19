# C++基础

## 基础特点

* 头文件

  * C++代码中，导入头文件，编译器会在实际创建可执行文件前将头文件中的代码加入程序，

* 输入：

  * 用户按回车时，回车键也会作为字符输入，需要丢弃。

* True和False

  * 计算机术语中的True和False：True 语句的计算结果为非零数，false 语句的计算结果为零。
  * 关系操作符作用于两数时，如果为true则返回1，否则返回0

* 布尔操作符：

  * ！，&&，||。
  * 优先级：！，&&，||。

* 原型：

  函数原型：

  ```c++
  int mult ( int x, int y ); // 分号结束
  ```

  函数定义：

  ```c++
  int mult ( int x, int y )
  {
    return x * y;
  }
  ```

  main函数内调用的函数的原型必须声明在main前，否则会报未定义错误，函数定义也有原型的作用。

  只要原型存在，即使没有定义，函数也可以使用可编译通过，但不能运行。
  
  

## 指针、数组和字符串

* 指针：指向**内存中的某个位置**，指针只是**存储内存地址的变量**，通常是其他变量的地址。

  * 分配内存时会返回一个起始地址，可以用一个指针接收。

  * 好处：直接转递地址，避免复制

  * 缺点：使用指针必须初始化，否则其可能指向一个随机的内存地址。

  * 声明指针

    ```c++
    <variable_type> *<name>;  // variable_type标明指向哪种类型的内存地址
    ```

    如果你在同一行上声明多个指针，你必须在每个指针前面加一个星号:

    ```c++
    // one pointer, one regular int
    int *pointer1, nonpointer1;
     
    // two pointers
    int *pointer1, *pointer2;
    ```

  * 访问指针的信息

    * 获取指针指向的地址：无需*。
    * 获取指向的地址上对应类型的值：加上*。【取消指针的引用; 实质上，是**获取对某个内存地址的引用并跟踪它**，以检索实际值。】

  * 获取变量的内存地址已便赋值给指针：

    & 符号。被称为 address-of 操作符，因为它返回内存地址。

    ```c++
    #include <iostream>
     
    using namespace std;
     
    int main()
    { 
      int x;            // A normal integer
      int *p;           // A pointer to an integer
     
      p = &x;           // Read it, "assign the address of x to p"
      cin>> x;          // Put a value in x, we could also use *p here
      cin.ignore(); // 忽略回车字符
      cout<< *p <<"\n"; // Note the use of the * to get the value
      cin.get(); //提取元字符
    }
    ```

  * new关键字会从空闲区中分配对应类型的内存，并返回地址。【系统内存不足而调用 new 失败，那么它将“抛出异常”。】

    ```c++
    int *ptr = new int;
    *ptr = 1; // 改变值
    ```
    
    其指向的内存对其他程序不可用，意味着需要释放分配的内存。
    
    ```c++
    delete ptr; // delete释放通过 new 分配的内存。
    ```
    
    回收内存后，可将指针值置为0，这时指针就变成了**空指针**即它什么也没指向。

* Structure：

  结构体类似类，其内部可以存储许多不同类型的值。

  union：也可存储不同类型的值，但每次只能存储一个，默认大小为最大类型的。

  声明格式：

  ```c++
  struct Tag {
   Members
  };
  ```

  使用例子：

  ```c++
  struct database {
    int id_number;
    int age;
    float salary;
  };
   
  int main()
  {
    database employee;  //There is now an employee variable that has modifiable  初始化变量
                        // variables inside it.
    employee.age = 22;
    employee.id_number = 1;
    employee.salary = 12000.21;
  }
  ```

  使用指针存储结构体变量地址，并对内部数据访问：

  ```c++
  #include <iostream>
   
  using namespace std;
   
  struct xampl {
    int x;
  };
   
  int main()
  {  
    xampl structure;
    xampl *ptr;
     
    structure.x = 12;
    ptr = &structure; // Yes, you need the & when dealing with structures
                      //  and using pointers to them
    cout<< ptr->x;    // The -> acts somewhat like the * when used with pointers 指针指向对应的成员
                      //  It says, get whatever is at that memory address
                      //  Not "get what that memory address is"
    cin.get();                    
  }
  ```

* 数组：

  声明：

  ```c++
  int twodimensionalarray[8][8];
  ```

  与指针搭配

  ```c++
  char *ptr;
  char str[40];
  ptr = str;  // Gives the memory address without a reference operator(&) 数组名指向了第一个元素的地址
  ```

  释放数组：

  ```c++
  delete [] arry.
  ```

* C格式字符串：实际上是字符数组，存储超过一个字符，结尾永远是'\0'【空字符，实际上是告诉编译器你指的是新的一行】。

  声明：

  ```c++
  "This is a static string"  //字符串常量
  char string[50]; // 声明最大存储49个字符的字符串
  char *array = new char[256]; // 字符串指针
  ```

  输入字符串：

  * cin>>：会在读取第一个空格后终止这个字符串。、
  * cin.getline(char* buffer,int length,char terminal_char)：buffer为字符串地址，length为最大接收长度，最后为终止字符【终止字符是回车'\n'】。

  cstring文件中相关操作字符串的函数：

  * ```c++
    // 比较大小【大小写敏感】
    int strcmp ( const char *s1, const char *s2 );
    
    // 拼接，将第二个字符串拼接到第一个后面，需确保第一个够大
    char *strcat ( char *dest, const char *src );
    
    // 复制，将第二个字符串复制到第一个
    char *strcpy ( char *dest, const char *src );
    
    // 长度 减去终止字符(“0”) 
    size_t strlen ( const char *s );
    ```

    上面的字符串函数**都依赖于字符串末尾的空终止符**。

  * 例子：
  
    ```c++
    int testArray() {
    	char* string = new char[256];
    	cin.getline(string, 255, '\n');
    	cout <<(strcmp("abcd", string));
    	delete[] string;
    	return 0;
    }
    ```
  
    





## 文件IO、命令行参数和类

* 文件IO

  * 头文件fstream中两个操作文件的基本类：

    * Ifstream：文件输入
    * Ofstream：文件输出

  * 声明实例： 【两个基本类都适用】

    ```c++
    ifstream a_file;
    
    ifstream a_file ( "filename" ); //此构造器将会打开文件对应流
    ```

  * 对应函数：

    open()：打开文件流

    close()：关闭文件流

    is_open()：文件是否打开【确保文件打开后再处理】

  * C++重载操作符，所以在类的实例前面使用 < < 和 > ，就好像它是 cout 或 cin 一样。

    ```c++
    #include <fstream>
    #include <iostream>
     
    using namespace std;
     
    int main()
    {
      char str[10];
     
      //Creates an instance of ofstream, and opens example.txt
      ofstream a_file ( "example.txt" );
      // Outputs to example.txt through a_file
      a_file<<"This text will now be inside of example.txt";
      // Close the file stream explicitly
      a_file.close();
      //Opens for reading the file
      ifstream b_file ( "example.txt" );
      //Reads one string from the file
      b_file>> str;
      //Should output 'this'
      cout<< str <<"\n";
      cin.get();    // wait for a keypress
      // b_file is closed implicitly here
    }
    ```

  * 带文件名参数的ofstream构造函数的模式：**如果文件不存在，就创建它; 如果文件中存在某些内容，则删除其中的所有内容。**

    带另一个参数的构造函数指明**文件如何被处理**：

    ```c++
    ofstream a_file ( "test.txt", ios::app );
    
    ios::app   -- Append to the file
    ios::ate   -- Set the current position to the end
    ios::trunc -- Delete everything in the file
    ```

* 类型转换：

  ```c++
  // C格式类型转换：
  cout<< (char)65 <<"\n"; 
  
  // 函数式转换：
  cout<< char ( 65 ) <<"\n"; 
  ```

  4种命名式转换

  ```c++
  cout<< static_cast<char> ( 65 ) <<"\n"; 
  // static_cast，const_cast, reinterpret_cast, and dynamic_cast
  ```

  用途：强制执行正确的数学运算类型。如整数除法只能得到整数，要获得小数可转为float。

* 类

  * C++相比于C多了**面向对象的特性和泛型的支持**。

  * 对象是真实世界对象的基本定义。类是与单个对象类型相关的数据集合。类不仅包含关于真实世界对象的信息，还包含访问数据的函数，而且类具有从其他类继承的能力。【封装思想】

    * 类中含有变量和函数【通常是函数原型】，并有public、protected、private访问权限修饰符修饰，且有必须含有构造函数和析构函数【都无返回类型】，基本思想是让构造函数初始化变量【**声明类的实例时，构造函数将被自动调用**】，在类之后清除析构函数，包括释放所有分配的内存【**总是在类不再可用时调用析构函数**】。

    例子：

    ```c++
    #include <iostream>
     
    using namespace std;
     
    class Computer // Standard way of defining the class
    {
    public:
      // This means that all of the functions below this(and any variables)
      //  are accessible to the rest of the program.
      //  NOTE: That is a colon, NOT a semicolon...
      Computer(); 
      // Constructor 【构造函数的函数原型】
      ~Computer();
      // Destructor 【析构函数】
      void setspeed ( int p );
      int readspeed();
    protected:
      // This means that all the variables under this, until a new type of
      //  restriction is placed, will only be accessible to other functions in the
      //  class.  NOTE: That is a colon, NOT a semicolon...
      int processorspeed;
    };
    // Do Not forget the trailing semi-colon 【注意分号】
     
    Computer::Computer() // 【类外部定义函数语法，Computer指明实际的类】
    {
      //Constructors can accept arguments, but this one does not
      processorspeed = 0;
    }
     
    Computer::~Computer()
    {
      //Destructors do not accept arguments
    }
     
    void Computer::setspeed ( int p )
    {
      // To define a function outside put the name of the class
      //  after the return type and then two colons, and then the name
      //  of the function.
      processorspeed = p;
    }
    int Computer::readspeed()  
    {
      // The two colons simply tell the compiler that the function is part
      //  of the class
      return processorspeed;
    }
     
    int main()
    {
      Computer compute;  
      // To create an 'instance' of the class, simply treat it like you would
      //  a structure.  (An instance is simply when you create an actual object
      //  from the class, as opposed to having the definition of the class)
      compute.setspeed ( 100 ); 
      // To call functions in the class, you put the name of the instance,
      //  a period, and then the function name.
      cout<< compute.readspeed();
      // See above note.
    }
    ```

* 内联函数：基本思想是用空间换时间加快运行速度，类似占位符，编译器会将内联函数调用处替换为内联函数的代码，适合于小函数。【对于大的内联函数，编译器会直接调用】

  ```c++
  #include <iostream>
   
  using namespace std;
   
  inline void hello() // 定义了内联函数
  { 
    cout<<"hello";
  }
  int main()
  {
    hello(); //Call it like a normal function...
    cin.get();
  }
  ```

* 命令行参数

  * 可在命令行OS（DOS、Linux）中传递参数给C++程序，main函数接收两个参数，一个是参数个数表示参数个数，**其包含程序名称**。一个参数表示参数列表，Argv [0]是程序的名称，如果该名称不可用，则为空字符串。在此之后，每个小于 argc 的元素都是一个命令行参数。您可以像**使用字符串一样使用每个 argv 元素**，或者使用 argv 作为二维数组。Argv [ argc ]是空指针。

    ```c++
    int main ( int argc, char *argv[] )；
    ```

    ```c++
    #include <fstream>
    #include <iostream>
     
    using namespace std;
     
    int main ( int argc, char *argv[] )
    {
      if ( argc != 2 ) // argc should be 2 for correct execution
        // We print argv[0] assuming it is the program name
        cout<<"usage: "<< argv[0] <<" <filename>\n";
      else {
        // We assume argv[1] is a filename to open
        ifstream the_file ( argv[1] );
        // Always check to see if file opening succeeded
        if ( !the_file.is_open() )
          cout<<"Could not open file\n";
        else {
          char x;
          // the_file.get ( x ) returns false if the end of the file
          //  is reached or an error occurs
          while ( the_file.get ( x ) )
            cout<< x;
        }
        // the_file is closed implicitly here
      }
    }
    ```




## 链表、二叉树、递归

* 链表结构：

  * 声明：

    ```c++
    struct node {
      int x;
      node *next;
    };
     
    int main()
    {
      node *root;      // This will be the unchanging first node
     
      root = new node; // Now root points to a node struct
      root->next = 0;  // The node root points to has its next pointer
                       //  set equal to a null pointer
      root->x = 5;     // By using the -> operator, you can modify the node
                       //  a pointer (root in this case) points to.
    }
    ```

  * 循环操作：

    ```c++
    conductor = root;
    while ( conductor != NULL ) {
      cout<< conductor->x;
      conductor = conductor->next;
    }
    ```

* 递归：

  * 例子：

    ```c++
    void doll ( int size )
    {
      if ( size == 0 )   // No doll can be smaller than 1 atom (10^0==1) so doesn't call itself
        return;          // Return does not have to return something, it can be used
                         //  to exit a function
      doll ( size - 1 ); // Decrements the size variable so the next doll will be smaller.
    }
    int main()
    {
      doll ( 30 ); //Starts off with a large doll (it's a logarithmic scale)
    }
    ```

* 使用va_list接收可变参数列表

  * 使用可变创数列表

    * 包含cstdarg头文件
    * 使用va_list存储参数列表
    * 使用va_start初始化列表
    * 使用va_arg返回列表中的下一个参数
    * 使用va_end清理参数列表

    ```c++
    #include <cstdarg>
    #include <iostream>
     
    using namespace std;
     
    // this function will take the number of values to average
    // followed by all of the numbers to average
    double average ( int num, ... ) // 声明格式
    {
      va_list arguments;                     // A place to store the list of arguments
      double sum = 0;
     
      va_start ( arguments, num );           // Initializing arguments to store all values after num
      for ( int x = 0; x < num; x++ )        // Loop until all numbers are added
        sum += va_arg ( arguments, double ); // Adds the next value in argument list to sum.  以double类型读取下一个参数
      va_end ( arguments );                  // Cleans up the list
     
      return sum / num;                      // Returns the average
    }
    int main()
    {
        // this computes the average of 12.2, 22.3 and 4.5 (3 indicates the number of values to average)
      cout<< average ( 3, 12.2, 22.3, 4.5 ) <<endl;
        // here it computes the average of the 5 values 3.3, 2.2, 1.1, 5.5 and 3.3
      cout<< average ( 5, 3.3, 2.2, 1.1, 5.5, 3.3 ) <<endl;
    }
    ```

  * 缺陷：

    * 需确保参数列表每个参数的类型是固定的，可能会有安全问题。

* 二叉树

  * 结构定义：

    ```c++
    struct node
    {
      int key_value;
      node *left;
      node *right;
    };
    ```

  * 创建一个二叉树类，将树的工作封装到一个单独的区域中，并使其可重用。

    ```c++
    class btree
    {
        public:
            btree();
            ~btree();
     
            void insert(int key);
            node *search(int key);
            void destroy_tree(); // 为了保存内存，需要包含一个删除树的函数。
     
        private:
            void destroy_tree(node *leaf);
            void insert(int key, node *leaf);
            node *search(int key, node *leaf);
             
            node *root;
    };
    
    btree::btree()
    {
      root=NULL;
    }
    
    btree::~btree()
    {
      destroy_tree();
    }
    
    void btree::destroy_tree(node *leaf)
    {
      if(leaf!=NULL)
      {
        destroy_tree(leaf->left);
        destroy_tree(leaf->right);
        delete leaf;
      }
    }
    
    // 二叉搜素树处理
    void btree::insert(int key, node *leaf)
    {
      if(key< leaf->key_value)
      {
        if(leaf->left!=NULL)
         insert(key, leaf->left);
        else
        {
          leaf->left=new node;
          leaf->left->key_value=key;
          leaf->left->left=NULL;    //Sets the left child of the child node to null
          leaf->left->right=NULL;   //Sets the right child of the child node to null
        }  
      }
      else if(key>=leaf->key_value)
      {
        if(leaf->right!=NULL)
          insert(key, leaf->right);
        else
        {
          leaf->right=new node;
          leaf->right->key_value=key;
          leaf->right->left=NULL;  //Sets the left child of the child node to null
          leaf->right->right=NULL; //Sets the right child of the child node to null
        }
      }
    }
    
    node *btree::search(int key, node *leaf)
    {
      if(leaf!=NULL)
      {
        if(key==leaf->key_value)
          return leaf;
        if(key<leaf->key_value)
          return search(key, leaf->left);
        else
          return search(key, leaf->right);
      }
      else return NULL;
    }
    
    
    void btree::insert(int key)
    {
      if(root!=NULL)
        insert(key, root);
      else
      {
        root=new node;
        root->key_value=key;
        root->left=NULL;
        root->right=NULL;
      }
    }
    
    node *btree::search(int key)
    {
      return search(key, root);
    }
    
    void btree::destroy_tree()
    {
      destroy_tree(root);
    }
    ```

## 继承和类设计

* 继承
  * 继承允许您创建类的层次结构，当您拥有描述一组对象的更一般的对象类时，应该使用继承。
  
* 继承语法：

  * ```c++
    class Animal
    {
      public:
      Animal();
      ~Animal();
      void eat();
      void sleep();
      void drink();
     
    private:
      int legs;
      int arms;
      int age;
    };
    //The class Animal contains information and functions
    //related to all animals (at least, all animals this lesson uses)
    class Cat : public Animal
    {
      public:
      int fur_color;
      void purr();
      void fish();
      void markTerritory();
    };
    //each of the above operations is unique
    //to your friendly furry friends
    //(or enemies, as the case may be)
    ```

  * 派生类可获取基类的public和protected修饰的数据

* 类设计

  * 理解接口

    * 设计类时应先设计接口，它决定了您的类如何与外部世界进行交互。
    * 多态：父类和子类存在同名函数，父类指针指向子类对象，静态类型为子类，调用同名函数时，调用子类的方法。

  * 虚函数

    * 当实现可能因子类而异时，函数应该是虚拟的。反之亦然，只要一个函数不应该改变，那么它就应该是非虚拟的。

    ```c++
    class TrafficWatch
    {
            public:
            // Packet is some class that implements information about network
            // packets
            void addPacket (const Packet& network_packet);
     
            int getAveragePacketSize ();
     
            int getMaxPacket ();
     
            virtual bool isOverloaded ();
    };
    ```

* 初始化列表：为某个类中的字段赋值，创建这个类。

  * 对象生命周期的开始：父类构造函数被调用，所有属于该类的对象的构造函数被调用。

    默认调用无参构造函数。

    调用父类有参构造函数：

    ```c++
    #include <iostream>
    class Foo
    {
            public:
            Foo( int x ) 
            {
                    std::cout << "Foo's constructor " 
                              << "called with " 
                              << x 
                              << std::endl; 
            }
    };
     
    class Bar : public Foo
    {
            public:
            Bar() : Foo( 10 )  // construct the Foo part of Bar
            { 
                    std::cout << "Bar's constructor" << std::endl; 
            }
    };
     
    int main()
    {
            Bar stool;
    }
    ```

    调用类的字段对象的构造函数

    ```c++
    class Baz
    {
            public:
                    Baz() : _foo( "initialize foo first" ), _bar( "then bar" ) { }  // 相当于赋值语句 按照声明顺序
     
            private:
            std::string _foo;
            std::string _bar;
    };
    ```

    构造参数中参数名和参数类型与某个字段名相同相当于直接赋值。

    ```c++
    class Baz
    {
            public:
                    Baz( std::string foo ) : foo( foo ) { }
            private:
                std::string foo;
    };
    
    // 相当于
    class Baz
    {
            public:
                    Baz( std::string foo )
                    {
                        this->foo = foo;
                    }
            private:
                std::string foo;
    };
    ```

    使用泛型初始化

    ```c++
    template <class T>
    class my_template
    {
            public:
                    // works as long as T has a copy constructor
                    my_template( T bar ) : _bar( bar ) { }
     
            private:
                    T _bar;
    };
    ```

    常量字段**必须在初始化列表中初始化**，其只能初始化一次。

    ```c++
    class const_field
    {
            public:
                    const_field() : _constant( 1 ) { }
                    // this is an error: const_field() { _constant = 1; } 
     
            private:
                    const int _constant;
    };
    ```

  * 何时需要初始化列表

    * 字段或父类无默认构造函数时，必须选择相应的构造函数
    * 存在引用字段，引用只能被初始化一次。

  * 初始化过程中可能出现异常，我们可以捕获并抛出

    ```c++
    class Foo
    {
            Foo() try : _str( "text of string" ) 
            { 
            } 
            catch ( ... ) 
            { 
                    std::cerr << "Couldn't create _str";
                    // now, the exception is rethrown as if we'd written
                    // "throw;" here
            }
    };
    ```

  * 总结：

    * 在运行构造函数体之前，先调用其父类的构造函数，然后再调用其字段。默认情况下，调用无参数构造函数。初始化列表允许您选择调用哪个构造函数以及构造函数接收哪些参数。
    * 如果您有一个引用或 const 字段，或者如果使用的某个类没有默认构造函数，那么您必须使用一个初始化列表。
    
  * 例：
  
    ```c++
    class Foo {
    public:
    	Foo(int x) {
    		cout << "foo create " << x << endl;
    
    	}
    };
    template <class T>
    class Bar : public Foo {
    public:
    	Bar(string _foo, T temp) 
    		:Foo(19), _foo(_foo), _bar("123456"), _const(1), temp(temp) // 初始化列表，显示调用有参构造函数
    	{ 
    
    	};
    public:
    	string _foo;
    	string _bar;
    	const int _const;
    	T temp;
    };
    
    void testInital() {
    	Bar<int> bar("1234", 12); // 根据构造函数实例化
    	cout << bar._foo << endl;
    	cout << bar._bar << endl;
    	cout << bar._const << endl;
    	cout << bar.temp << endl;
    	// 输出：
    	//	foo create 19
    	//	1234
    	//	123456
    	//	1
    	//	12
    }
    ```
  
    

## 模板

* 模板

  * 模板即所谓的泛型。

  * 声明模板类的语法

    ```c++
    template <class a_type> class a_class {...};
    // a_type表示某个数据类型的标识符
    ```

    使用模板类中模板的变量：

    ```c++
    a_type a_var;
    ```

    使用模板类中模板的函数：

    ```c++
    template<class a_type> void a_class<a_type>::a_function(){...}
    ```

    定义模板类实例：

    ```c++
    a_class<int> an_example_class;
    ```

  * 例子：

    ```c++
    template <class T> class Calc {
    public :
    	Calc(T init): init(init){
    	};
    	T multiply(T x, T y) {
    		return x * y;
    	};
    	T add(T x, T y);
    	T init;
    };
    template <class T> T Calc<T>:: add(T x, T y) {
    	return x + y;
    }
    
    void testTemplateClass() {
    	Calc<int> calc(2);
    	cout<<calc.add(2, 3)<<endl;
    	cout << calc.init << endl;
    	cout << calc.multiply(2, 3) << endl;
    }
    ```

  * 模板可以使程序更加通用，并允许以后重用代码。

* 模板函数

  * 模板即可作用于类，又可作用于函数。

  * 模板函数相比于模板类更加容易使用，**因为编译器通常可以从函数的参数列表推导出所需的类型。**

  * 模板函数语法：

    ```c++
    template <class type> type func_name(type arg1, ...);
    ```

    调用方式：

    ```c++
    int x = add(1, 2);
    // 等同于
    int x = add<int>(1, 2);
    ```

  * 模板类和模板函数

    模板类中可以有与之不同模板的模板函数【不同的模板形参】

    ```c++
    template <class type> class TClass
    {
        // constructors, etc
         
        template <class type2> type2 myFunc(type2 arg);
    };
    ```

    定义函数时需携带两个模板:

    ```c++
    template <class type>  // For the class
        template <class type2>  // For the function
        type2 TClass<type>::myFunc(type2 arg)
        {
            // code
        }
    ```

  * 例子：

    ```c++
    template <class T> class Calc {
    public :
    	Calc(T init): init(init){
    	};
    	T multiply(T x, T y) {
    		return x * y;
    	};
    	T add(T x, T y);
    
    	template<class A> A sub(A a, A b) {
    		return a - b;
    	}
    	T init;
    };
    template <class T> T Calc<T>:: add(T x, T y) {
    	return x + y;
    }
    
    void testTemplateClass() {
    	Calc<int> calc(2);
    	cout<<calc.add(2, 3)<<endl;
    	cout << calc.init << endl;
    	cout << calc.multiply(2, 3) << endl;
    	cout << calc.sub<int>(3, 2) << endl;
    }
    ```

    

* 模板专门化和部分模板专门化

  * 模板专门化

    * 模板专用化的思想是**覆盖默认的模板实现**，以不同的方式**处理特定的类型**。

    * 实现：除了模板类以外，还为相应类型定义模板

      ```c++
      template <typename T>
      class vector
      {
          // accessor functions and so forth
          private:
          T* vec_data;   // we'll store the data as block of dynamically allocated 
                         // memory
          int length;    // number of elements used 
          int vec_size;  // actual size of vec_data
      };
      
      
      template <>
      class vector <bool>
      {
          // interface
       
          private:
          unsigned int *vector_data;
          int length;
          int size;
      };
      ```

    * 例子：

      ```c++
      template <typename T> class vector {
      public:
      	T* vec_data;
      	int length;
      	int vec_size;
      };
      template<> class vector<bool> {
      public:
      	unsigned int* vector_data;
      	int length;
      	int size;
      };
      
      void templateParti() {
      	vector<char> vectorChar;
      	vectorChar.vec_data = new char[29];
      	vector<bool> vectorBool;
      	vectorBool.vector_data = new unsigned int[20];
      	cout << *(vectorChar.vec_data) << endl;
      	cout << *(vectorBool.vector_data) << endl;
      }
      ```

    * 适用情况：

      * 根据类型向一个模板类添加额外的方法，而不是向其他模板添加额外的方法。
      * 如果您的模板类型依赖于某些行为，而这些行为并未在您希望存储在该模板中的类集合中实现，那么您可能希望对**某些模板进行专门化**。

  * 部分模板专门化

    * 声明处理任何指针类型的部分专用模板

      ```c++
      template <typename T>
      class sortedVector<T *> // 告诉编译器将任何类型的指针与此模板而不是更通用的模板匹配
      {
          public:
          // same functions as before.  Now the insert function looks like this:
          insert( T *val )
          {
              if ( length == vec_size )   // length is the number of elements
              {
                  vec_size *= 2;    // we'll just ignore overflow possibility!
                  vec_data = new T[vec_size];
              }
              ++length;  // we are about to add an element
               
              // we'll start at the end, sliding elements back until we find the
              // place to insert the new element
              int pos;
              for( pos = length; pos > 0 && *val > *vec_data[pos - 1]; --pos )
              {
                  vec_data[pos] = vec_data[pos - 1];
              }
              vec_data[pos] = val;
          }
       
          private:
          T** vec_data;
          int length;
          int size;
      };
      ```

    * 模板参数部分专门化

      ```c++
      //  指定要存储的类型和向量的长度
      template <typename T, unsigned length>
      class fixedVector { ... };
      
      // 部分专门化布尔值
      template <unsigned length>
      class fixedVector<bool, length> {...}
      ```

  * 多个模板时，编译器将选择**最具体的模板特化**。



## 枚举、预处理器、格式化输出和随机数

* 枚举类型

  * 枚举类型背后的思想是创建新的数据类型，这些数据类型只能接受有限范围的值。此外，这些**值都是用常量表示**的——事实上，不需要知道潜在的值。对于**比较值的目的，常量的名称应该足够了。**

  * 声明枚举类型：

    ```c++
    enum wind_directions_t {NO_WIND, NORTH_WIND, SOUTH_WIND, EAST_WIND, WEST_WIND}; // 声明时指定可能的值 wind_directions_t表示枚举类型的类型名称
    ```

    声明对应常量：

    ```c++
    wind_directions_t wind_direction = NO_WIND;//值只能为上边的五个
     
    wind_direction = 453; // doesn't work, we get a compiler error! 
    
    ```

    **这些常量的默认为整型，默认值从零开始，并逐步增加1。**【给常量比较时将用这些值】

    给常量显式值：

    ```c++
    enum wind_directions_t {NO_WIND = 4, NORTH_WIND = 3, SOUTH_WIND = 2, EAST_WIND = 1, WEST_WIND = 0};
    ```

  * 打印枚举常量：

    **默认情况下的打印将输出对应整数值**。
    
  * 类型正确性：
  
    * 枚举常量可直接赋值给整型变量
  
      ```c++
      int my_wind = EAST_WIND;
      
      // or
      wind_directions_t wind_direction = NO_WIND;
       
      int my_wind = wind_direction;
      ```
  
    * 将输入转为枚举类型：通过请求一个字符串，然后通过将输入与可能的输入字符串进行比较来验证输入，从而选择分配枚举的常量，从而保护用户不受枚举的影响。
  
      ```c++
      std::cout << "Please enter NORTH, SOUTH, EAST, WEST, or NONE for our wind direction";
      std::cout << std::endl;
       
      string user_wind_dir;
      cin >> user_wind_dir;
       
      wind_directions_t wind_dir;
       
      if ( user_wind_dir == "NORTH" )
      {
              wind_dir = NORTH_WIND;
      }
      else if ( user_wind_dir == "SOUTH" )
      {
              wind_dir = SOUTH_WIND;
      }
      else if ( user_wind_dir == "EAST" )
      {
              wind_dir = EAST_WIND;
      }
      else if ( user_wind_dir == "WEST" )
      {
              wind_dir = WEST_WIND;
      }
      else if ( user_wind_dir == "NONE" )
      {
              wind_dir = NO_WIND;
      }
      else
      {
              std::cout << "That's not a valid direction!" << std::endl;
      }
      ```
  
  * 总结：
  
    * 好处：
      * 枚举允许约束变量的值。
      * 枚举可以用来使您的程序更具可读性。
      * 枚举可用于快速声明一个常量值范围，而不需要使用 # define。
    * 注意点：
      * 必须谨慎地命名枚举常数，以避免名称冲突。
      * 枚举不工作“多态”，除非从整型，这可能是不方便的。
  
* C预处理器：

  * C 预处理器在将源代码文件交给编译器之前对其进行修改。您很可能习惯于使用预处理器将文件直接include到其他文件中，或者 # define 常量，但是预处理器也可以用于使用编译时展开的宏创建“inline”代码，并防止代码被编译两次。

  * 预处理器的三个作用

    * 指令：让预处理器跳过文件的一部分、包含另一个文件或者define一个常量或宏的命令。指令总是以一个尖锐的标志(#)开头，为了可读性，应该将其置于页面的左侧。
    * 常量：处理#define 常量。
    * 宏：处理宏。
    * **通常，常量和宏都用全大写字母表示，以表明它们是特殊的。**

  * 头文件

    * #include指令让预处理器获取文件的文本并将其直接放置到当前文件中。通常，这样的语句放在程序的顶部。

  * 常量：

    * 定义格式：

      ```c++
      #define [identifier name] [value]
      ```

      文件中常量标识符会直接被值代替。

    * // 数学表达式定义
      #define PI_PLUS_ONE (3.14 + 1)

      避免**运算顺序问题**破坏常量的含义。

  * 条件编译

    * 预处理器可通过加入一些指令来将文件交给编译器之前将一些代码移除掉。

    * 这些指令包括 \#if, #elif, #else, #ifdef, #ifndef，且都通过\#endif闭合，false条件内的代码将被排除。

    * 例子：

      ```c++
      #if 0
       
      // code 内部代码将不会执行
       
      #endif
      ```

      








## C++与Java差异

### 语法差异

* main 函数

  * 格式：

    ```c++
    // free-floating function
    int main( int argc, char* argv[])
    {
        printf( "Hello, world" );
    }
    ```

* 编译和启动

  * 指令：

    ```txt
    	// compile as
        g++ foo.cc -o outfile
        // run with
        ./outfile
    ```

* 注释：相同 (//和/* */）

* 类声明：

  * C++多了分号

    ```c++
    class Bar {};
    ```

* 方法声明：大致相同，但C++方法没有public/private/protected前缀且不一定是类的一部分。

* 构造函数和析构函数：C++构造函数语法与Java相同，且有析构函数的概念。

* 静态方法和静态变量：语法相同，但C++没有静态初始化块的概念。

* 调用静态方法：C++格式：Class::method

  ```c++
  class MyClass
  {
      public:
      static doStuff();
  };
  
  // now it's used like this
  MyClass::doStuff();
  ```

* 对象声明：

  ```c++
      // 分配在栈中
      myClass x;
  
      // or 在堆中
      myClass *x = new myClass;
  ```

* 访问对象的变量：

  * 如果对象基于堆栈

    ```c++
    myClass x;
    x.my_field; // ok
    ```

  * 使用指针时：

    ```c++
    myClass x = new MyClass;
    x->my_field; // ok
    ```

* 继承：

  ```c++
  class Foo : public Bar
      { ... };
  ```

* 访问权限控制：

  ```c++
      public:
          void foo();
          void bar();
      
  ```

* 虚函数【抽象函数】：

  ```c++
  virtual int foo();
  ```

* 抽象类：类声明无需额外修饰符，只需要有虚函数。

  ```c++
     // just need to include a pure virtual function
      class Bar { public: virtual void foo() = 0; };
      
  ```

* 内存管理

  内存分配大致相同，但C++没有gc故需要自行内存回收

* NULL和null：C++使用NULL，Java使用null

  ```c++
  // initialize pointer to NULL
      int *x = NULL;
  ```

* 布尔值：C++对应类型是bool，而Java是boolean

* 常量声明：C++使用const，Java使用final

  ```c++
  const int x = 7;
  ```

* 抛出异常：C++不像Java那样必须声明方法可能要抛出的异常

  ```c++
  int foo() throw (IOException)
  ```

* 数组：C++需要回收数组的内存

  ```c++
  	int x[10];
      // or 
      int *x = new x[10];
      // use x, then reclaim memory
      delete[] x;
  ```

* 集合和迭代器

  C++中迭代器是集合中的成员，其开始是 < container >.begin()，结束是< container >.end()，前进使用++运算符，访问使用*

  ```c++
   	vector myVec;
      for ( vector<int>::iterator itr = myVec.begin();
            itr != myVec.end();
            ++itr )
      {
          cout << *itr;
      }
  ```



### 其他差异

* 编译模型

  * Java编译完后，需要JVM加载Class文件才能运行，而C++编译完后即可运行。

* 库的引用

  * Java使用Import

  * C++使用include为库对象提供声明

    ```c++
    #include <string>
    using namespace std; //使用声明来提供短名称
    ```

    C++需要更长时间进行编译，因为 include 语句需要大量的解析。

* 内存分配

  * C++手动释放已分配的内存

    ```c++
    int *p_int = new int;
    // use p_int
    delete p_int;
    ```

  * 这意味着设计C++程序时需要注意是否安全进行了内存的释放和分配。

* 函数与类

  * C++中存在不属于类的独立函数

* 安全性

  * Java非常具有安全性，其具有诸如范围检查数组、不可变字符串、自动调整容器大小和垃圾收集等特性，这些特性可以防止许多常见的安全问题。

  * C++则没有这么高的安全性，因此编写程序时需要注意。

    ```c++
    int values[ 10 ];
    values[ 20 ] = 2; // 直接写入，不会报错。
    ```

* 基于栈的对象

  * C++中可以直接将对象分配在栈中，以减少动态内存分配提高性能。

    ```c++
    MyClass c; // no memory allocated, still calls the MyClass constructor
    ```

* 多态语法：

  * 在 c + + 中，因为可以有基于堆栈的对象，所以必须有处理指针或引用的特殊语法。

    ```c++
    #include <string>
    #include <iostream>
     
    using namespace std;
     
    class StringConvertable
    {
        public:
        virtual string toString () = 0;
    }; // note the need for a semicolon here in C++
     
    // no class is needed, we can have free-standing functions
    void displayObject (StringConvertable* obj)
    {
        // calls the virtual toString method on the concrete type passed in
        // the arrow operator is used to access methods of a pointed-to class
        cout << obj->toString() << '\n'; 
    }
    ```

* 析构函数(destuctor)

  * C + + 中的所有对象都有一个destuctor，这个destuctor保证在对象**被释放时调用。**
  * 对象何时释放：
    * 显示调用delete
    * 对象基于栈时，栈帧换出【方法调用结束，超出作用域】

* 库

  * 类似Java，C++也有提供大量工具集和容器的库，即The standard template library (STL)，STL 和 Java 类库分别使用**模板**或泛型。

  * 使用STL中的集合容器

    ```c++
    #include <vector>
     
    vector<int> v; // no allocation needed
    v.push_back( 10 );
    v.push_back( 20 );
    ```

