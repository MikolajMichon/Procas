import SwiftUI
import Combine

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

func TimeAsString (_ Time: Int, IncludeSeconds: Bool) -> String {
    let Minute = 60
    let Hour = Minute * 60
    
    let Hours = (Time >= Hour) ? String(Time / Hour) + "h " : ""
    let Minutes = (Time % Hour > 0) ? String(Time % Hour / Minute) + "m " : ""
    let Seconds = IncludeSeconds ? String(Time % Minute) + "s" : ""
    return (Time == 0) ? "0m" : Hours + Minutes + Seconds
}

enum ButtonTypes {
    case list, tasks, plus, reset, none
}

enum SettingTypes {
    case newTask, configureTask, newListing, configureListing, configureApp
}

enum OptionTypes {
    case title, duration, color, deleteTask, deleteListing, resetTask
}

enum ScreenTypes {
    case list, tasks, about, settings
}

let ButtonImages: [ButtonTypes:String] = [
    .list : "List",
    .tasks : "Tasks",
    .plus : "Plus",
    .reset : "Reset",
    .none : "Nothing"
]

let ButtonSizes: [ButtonTypes:CGFloat] = [
    .list : 30,
    .tasks : 30,
    .plus : 80,
    .reset : 40,
    .none : 0
]

let SettingOptions: [SettingTypes:[OptionTypes]] = [
    .newTask : [.title, .duration, .color],
    .configureTask : [.title, .duration, .color, .deleteTask, .resetTask],
    .newListing : [.title, .color],
    .configureListing : [.title, .color, .deleteListing],
    .configureApp : [.title]
]

let ScreenButtons: [ScreenTypes:[ButtonTypes]] = [
    .tasks : [.list, .plus, .reset],
    .settings : [.none, .plus, .none],
    .list : [.tasks, .plus, .reset],
    .about : [.tasks, .none, .list]
]

struct Task {
    var index: Int
    var title: String
    var color: Color
    var duration: Int
    var progress: Int = 0
    var active: Bool = false
}

struct Listing {
    var index: Int
    var title: String
    var color: Color
    var complete: Bool = false
    
}

struct ContentView: View {
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var Font = "AmericanTypewriter-Bold"
    @State var Colors: [Color] = [.red, .orange, .yellow, .green,.cyan, .blue, .purple, .brown, .gray]
    
    @State var Tasks: [Task] = []
    @State var List: [Listing] = []
    @State var Screen: ScreenTypes = .tasks
    @State var Title: String = "TIME TASKS"
    @State var Settings: SettingTypes = .newTask
    
    @State var M_Index = 1
    @State var M_Title = ""
    @State var M_Duration = ""
    @State var M_Color: Color = .cyan
    
    
    func ThemeText (_ DisplayText: String, _ Size: CGFloat) -> some View {
        return Text(DisplayText)
            .font(.custom(Font, size: Size))
            .foregroundColor(.black)
    }
    
    func ResetMemory() {
        M_Index = 1
        M_Title = ""
        M_Duration = ""
        M_Color = .cyan
    }
    
    func PlusButtonFunction() {
        switch Screen {
        case .tasks:
            Settings = .newTask
            Screen = .settings
            Title = "NEW TASK"
        case .list:
            Settings = .newListing
            Screen = .settings
            Title = "NEW LISTING"
        case .settings:
            switch Settings {
            case .newTask:
                M_Index = Tasks.count
                Tasks.append(Task(index: M_Index,title: (M_Title != "" ? M_Title : "New task"), color: M_Color, duration: Int(M_Duration != "" ? M_Duration : "60")!*60))
                Screen = .tasks
                Title = "TIME TASKS"
            case .configureTask:
                Tasks[M_Index].title = M_Title
                Tasks[M_Index].color = M_Color
                Tasks[M_Index].duration = Int(M_Duration)! * 60
                Screen = .tasks
                Title = "TIME TASKS"
            case .newListing:
                M_Index = List.count
                List.append(Listing(index: M_Index, title: M_Title != "" ? M_Title : "New listing", color: M_Color, complete: false))
                Screen = .list
                Title = "TO-DO LIST"
            case .configureListing:
                List[M_Index].title = M_Title
                List[M_Index].color = M_Color
                Screen = .list
                Title = "TO-DO LIST"
            default:
                print("Balls")
            }
            
            ResetMemory()
        default:
            print("Balls")
        }
    }
    
    func ResetButtonFunction() {
        switch Screen {
        case .tasks:
            for Index in 0..<Tasks.count {
                Tasks[Index].progress = 0
                Tasks[Index].active = false
            }
        case .list:
            for Index in 0..<List.count {
                List[Index].complete = false
            }
        default:
            print("Test")
        }
    }
    
    func TopBar() -> some View {
        return VStack{
            Rectangle()
                .frame(height: 80)
                .foregroundColor(.yellow)
                .blur(radius: 1)
                .overlay(HStack{
                    Image("Logo")
                        .resizable()
                        .frame(width: 60, height: 55)
                        .padding(.top, 20)
                    Spacer()
                    Image("Settings")
                        .resizable()
                        .frame(width: 45, height: 45)
                        .padding(.top, 25)
                }.padding(.trailing, 10)
                    .padding(.leading, 5))
            ThemeText(Title, 30)
                .frame(maxHeight: 40)
            Rectangle()
                .frame(height: 2)
                .padding(.leading, 15)
                .padding(.trailing, 15)
                .foregroundColor(.black)
        }
    }
    
    func BottomBar() -> some View {
        let Buttons: [ButtonTypes] = ScreenButtons[Screen]!
        return ZStack {
            LinearGradient(gradient: Gradient(colors: [.white, .yellow.opacity(0.5), .yellow.opacity(0.5)]),startPoint: .top, endPoint: .bottom)
            
            HStack {
                Spacer(minLength: 50)
                ForEach(0 ..< Buttons.count, id: \.self) {Index in
                    let BarButton = Buttons[Index]
                    Button(action: {
                        switch BarButton {
                        case .plus:
                            PlusButtonFunction()
                        case .reset:
                            ResetButtonFunction()
                        case .list:
                            Screen = .list
                            Title = "TO-DO LIST"
                        case .tasks:
                            Screen = .tasks
                            Title = "TIME TASKS"
                        case .none:
                            return
                        }
                    }) {
                        Circle()
                            .frame(width: BarButton == .plus ? 90 : 50 )
                            .padding(.leading, BarButton == .plus ? -5 : 15 )
                            .padding(.trailing, BarButton == .plus ? -5 : 15 )
                            .foregroundColor(.yellow)
                            .opacity(BarButton == .none ? 0 : (BarButton == .plus ? 1 : 0.7))
                            .overlay(
                                Image(ButtonImages[BarButton]!)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: ButtonSizes[BarButton]!)
                            )
                            .shadow(color: .gray, radius: 3, x: 0, y: 2)
                    }
                }
                
                Spacer(minLength: 50)
            }.padding(.bottom, 25)
                .padding(.top, -15)
        }
        .frame(maxWidth: .infinity, maxHeight: 100)
    }
    
    func ListingWindow (_ Listing: Listing) -> some View {
        return Rectangle()
            .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50)
            .cornerRadius(10, corners: [.topLeft, .bottomRight])
            .cornerRadius(50, corners: [.topRight, .bottomLeft])
            .foregroundColor(Listing.color)
            .brightness(0)
            .overlay(HStack{
                Button(action: {
                    List[Listing.index].complete.toggle()
                }) {
                    ZStack{
                        Circle()
                            .frame(width: 35, height: 35)
                            .foregroundColor(.white)
                            .opacity(0.4)
                        Image(Listing.complete ? "Check" : "Nothing")
                            .resizable()
                            .frame(width: 35, height: 35)
                    }
                }
                
                Spacer()
                
                ThemeText(Listing.title, 20)
                    .frame(height: 5)
                    
                Spacer()
                Button(action: {
                    Settings = .configureListing
                    M_Index = Listing.index
                    M_Title = Listing.title
                    M_Color = Listing.color
                    Screen = .settings
                    Title = "CHANGE LISTING"
                }) {
                    Image("Settings")
                        .resizable()
                        .frame(width: 40, height: 40, alignment: .center)
                        .padding(.top, 5)
                }
            }.padding(.top, 10)
                .padding(.bottom, 10)
                .padding(.leading, 10)
                .padding(.trailing, 10)
                     ,alignment: .leading)
            .shadow(color: .gray, radius: 3, x: 0, y: 4)
    }
    
    func TaskWindow (_ Task: Task) -> some View {
        return Rectangle()
            .frame(maxWidth: .infinity, minHeight: 115, maxHeight: 115)
            .cornerRadius(10, corners: [.topLeft, .bottomRight])
            .cornerRadius(50, corners: [.topRight, .bottomLeft])
            .foregroundColor(Task.color)
            .brightness(0)
            .overlay(HStack{
                ZStack {
                    Circle()
                        .foregroundColor(.white)
                        .opacity(0.4)
                    Circle()
                        .trim(from: 0, to: CGFloat(Double(Task.progress)/Double(Task.duration)))
                        .stroke(
                            .black,
                            style: StrokeStyle(
                                lineWidth: 10,
                                lineCap: .butt
                            )
                        )
                        .frame(width: 85)
                        .rotationEffect(.degrees(90))
                    Button(action: {
                        if Task.progress != Task.duration {
                            Tasks[Task.index].active.toggle()
                        }
                    }) {
                        Image((Task.progress == Task.duration) ? "Check" : (Task.active ? "Pause" : "Start"))
                            .resizable()
                            .frame(width: 35, height: 40)
                            .padding(.leading, Task.active ? 0 : 5)
                    }
                    
                }
                
                Spacer()
                VStack{
                    Spacer()
                    ThemeText(Task.title, 20)
                        .frame(height: 5)
                    ThemeText(TimeAsString(Task.progress, IncludeSeconds: true), 30)
                        .frame(height: 40)
                    ThemeText("Out of \(TimeAsString(Task.duration, IncludeSeconds: false))", 20)
                        .frame(height: 5)
                    Spacer()
                }
                Spacer()
                Button(action: {
                    Settings = .configureTask
                    M_Index = Task.index
                    M_Title = Task.title
                    M_Duration = String(Task.duration/60)
                    M_Color = Task.color
                    Screen = .settings
                    Title = "CHANGE TASK"
                }) {
                    Image("Settings")
                        .resizable()
                        .frame(width: 40, height: 40, alignment: .center)
                        .padding(.top, 75)
                }
            }.padding(.top, 10)
                .padding(.bottom, 10)
                .padding(.leading, 10)
                .padding(.trailing, 10)
                     ,alignment: .leading)
            .shadow(color: .gray, radius: 3, x: 0, y: 4)
    }
    
    func ListScreen () -> some View {
        return ScrollView {
            ForEach(0 ..< List.count, id: \.self) {Index in
                ListingWindow(List[Index])
            }
        }
    }
    
    func TasksScreen () -> some View {
        return ScrollView {
            ForEach(0 ..< Tasks.count, id: \.self) {Index in
                TaskWindow(Tasks[Index])
            }
        }
    }
    
    func OptionWindow (_ Option: OptionTypes) -> some View {
        switch Option {
        case .title:
            return AnyView(VStack {
                ThemeText("Title", 20)
                TextField(Settings == .newTask ? "New task" : "New listing", text: $M_Title)
                    .textFieldStyle(.roundedBorder)
            })
        case .duration:
            return AnyView(VStack {
                ThemeText("Duration", 20)
                TextField("60", text: $M_Duration)
                    .keyboardType(.numberPad)
                    .onReceive(Just(M_Duration)) { newValue in
                        let filtered = newValue.filter {"0123456789".contains($0)}
                        if filtered != newValue {
                            self.M_Duration = filtered
                        }
                    }
                    .textFieldStyle(.roundedBorder)
            })
        case .color:
            return AnyView(VStack {
                ThemeText("Color", 20)
                HStack {
                    ForEach(0 ..< Colors.count, id: \.self) {Index in
                        Button(action: {
                            M_Color = Colors[Index]
                        }) {
                            RoundedRectangle(cornerRadius: 15)
                                .frame(height: 40)
                                .foregroundColor(Colors[Index])
                        }
                    }
                }
            })
        case .deleteTask:
            return AnyView(VStack {
                Button(action:  {
                    Tasks.remove(at: M_Index)
                    for Index in M_Index..<Tasks.count {
                        Tasks[Index].index -= 1
                    }
                    Screen = .tasks
                    Title = "TIME TASKS"
                    ResetMemory()
                }) {
                    RoundedRectangle(cornerRadius: 10)
                        .overlay(ThemeText("Delete Task", 20))
                        .frame(height: 40)
                        .foregroundColor(.red)
                        .padding(.top, 10)
                }
            })
        case .deleteListing:
            return AnyView(VStack {
                Button(action:  {
                    List.remove(at: M_Index)
                    for Index in M_Index..<List.count {
                        List[Index].index -= 1
                    }
                    Screen = .list
                    Title = "TO-DO LIST"
                    ResetMemory()
                }) {
                    RoundedRectangle(cornerRadius: 10)
                        .overlay(ThemeText("Delete Listing", 20))
                        .frame(height: 40)
                        .foregroundColor(.red)
                        .padding(.top, 10)
                }
            })
        case .resetTask:
            return AnyView(VStack {
                Button(action:  {
                    Tasks[M_Index].progress = 0
                    Tasks[M_Index].active = false
                    Screen = .tasks
                    Title = "TIME TASKS"
                    ResetMemory()
                }) {
                    RoundedRectangle(cornerRadius: 10)
                        .overlay(ThemeText("Reset Task", 20))
                        .frame(height: 40)
                        .foregroundColor(.gray)
                        .padding(.top, 10)
                    
                }
            })
        }
    }
    
    func SettingsScreen () -> some View {
        let Options = SettingOptions[Settings]!
        return VStack {
            ForEach(0 ..< Options.count, id: \.self) {Index in
                OptionWindow(Options[Index])
            }
        }
    }
    
    var body: some View {
        VStack {
            TopBar()
            
            VStack {
                switch Screen {
                case .tasks:
                    TasksScreen()
                case .list:
                    ListScreen()
                case .settings:
                    SettingsScreen()
                case .about:
                    Spacer()
                }
            }.padding(.leading, 15)
                .padding(.trailing, 15)
            
            Spacer()
            BottomBar()
        }.frame(maxWidth: .infinity, alignment: .top)
            .background(.white)
            .ignoresSafeArea()
            .onReceive(timer) { _ in
                for Index in 0..<Tasks.count {
                    let Task = Tasks[Index]
                    if Task.active && Task.progress != Task.duration {
                        Tasks[Index].progress += 1
                    }
                }
            }
    }
}

