import SwiftUI
import Foundation

// MARK: - Language Manager
class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @Published var currentLanguage: Language = .english
    @AppStorage("selectedLanguage") private var selectedLanguageCode: String = "en"
    
    enum Language: String, CaseIterable {
        case english = "en"
        case chinese = "zh"
        case spanish = "es"
        
        var displayName: String {
            switch self {
            case .english: return "English"
            case .chinese: return "中文"
            case .spanish: return "Español"
            }
        }
        
        var flag: String {
            switch self {
            case .english: return "🇺🇸"
            case .chinese: return "🇨🇳"
            case .spanish: return "🇪🇸"
            }
        }
    }
    
    private init() {
        loadLanguage()
    }
    
    private func loadLanguage() {
        if let language = Language(rawValue: selectedLanguageCode) {
            currentLanguage = language
        }
    }
    
    func setLanguage(_ language: Language) {
        currentLanguage = language
        selectedLanguageCode = language.rawValue
    }
    
    // MARK: - Localized Strings
    func localizedString(_ key: LocalizationKey) -> String {
        switch currentLanguage {
        case .english:
            return key.english
        case .chinese:
            return key.chinese
        case .spanish:
            return key.spanish
        }
    }
}

// MARK: - Localization Keys
enum LocalizationKey {
    // App General
    case appName
    case appTagline
    case welcome
    case dashboard
    case habits
    case goals
    case settings
    case notifications
    case signOut
    case cancel
    case save
    case delete
    case edit
    case done
    case loading
    case error
    case success
    
    // Navigation
    case back
    case next
    case previous
    case close
    
    // Dashboard
    case todayTasks
    case weeklyProgress
    case monthlyGoals
    case yearlyGoals
    case bucketList
    case futureVision
    case aiInsights
    case focusCard
    case progressCard
    case progressOverview
    case todaysFocus
    case thisWeek
    case noTasksToday
    case moreTasks
    
    // Habits
    case addHabit
    case habitName
    case habitCategory
    case habitFrequency
    case habitDifficulty
    case habitCue
    case habitReward
    case habitStack
    case completedToday
    case streak
    case totalCompletions
    case habitTracker
    case buildHabits
    case todayProgress
    case filterByCategory
    case allCategories
    
    // Goals
    case addGoal
    case goalName
    case goalDescription
    case goalCategory
    case goalDeadline
    case goalProgress
    case goalCompleted
    
    // AI Insights
    case insights
    case personalizedTips
    case researchBased
    case actionableSteps
    
    // Settings
    case theme
    case darkMode
    case lightMode
    case language
    case account
    case changeName
    case changePassword
    case privacyPolicy
    
    // User Guide
    case userGuide
    case quickStart
    case gettingStarted
    case getStartedInMinutes
    case welcomeToMonu
    case mindfulPlanningCompanion
    case whatIsMonu
    case monuDescription
    case keyFeatures
    case dashboardOverview
    case dashboardDescription
    case dashboardFeatures
    case howToUse
    case howToUseDescription
    
    // Task Management
    case addTask
    case taskTitle
    case dailyPlanTasks
    case yearlyTasks
    case toDo
    case completed
    case proTips
    case researchBasedFeatures
    
    // Pomodoro
    case pomodoro
    case focus
    case shortBreak
    case longBreak
    case start
    case pause
    case reset
    case sessionComplete
    
    var english: String {
        switch self {
        case .appName: return "MONU"
        case .appTagline: return "Turn the dials, tune the moment"
        case .welcome: return "Welcome"
        case .dashboard: return "Dashboard"
        case .habits: return "Habits"
        case .goals: return "Goals"
        case .settings: return "Settings"
        case .notifications: return "Notifications"
        case .signOut: return "Sign Out"
        case .cancel: return "Cancel"
        case .save: return "Save"
        case .delete: return "Delete"
        case .edit: return "Edit"
        case .done: return "Done"
        case .loading: return "Loading..."
        case .error: return "Error"
        case .success: return "Success"
        case .back: return "Back"
        case .next: return "Next"
        case .previous: return "Previous"
        case .close: return "Close"
        case .todayTasks: return "Today's Tasks"
        case .weeklyProgress: return "Weekly Progress"
        case .monthlyGoals: return "Monthly Goals"
        case .yearlyGoals: return "Yearly Goals"
        case .bucketList: return "Bucket List"
        case .futureVision: return "Future Vision"
        case .aiInsights: return "AI Insights"
        case .focusCard: return "Focus Card"
        case .progressCard: return "Progress Card"
        case .progressOverview: return "Progress Overview"
        case .todaysFocus: return "Today's Focus"
        case .thisWeek: return "This Week"
        case .noTasksToday: return "No tasks for today ✨"
        case .moreTasks: return "more"
        case .addHabit: return "Add Habit"
        case .habitName: return "Habit Name"
        case .habitCategory: return "Category"
        case .habitFrequency: return "Frequency"
        case .habitDifficulty: return "Difficulty"
        case .habitCue: return "Cue"
        case .habitReward: return "Reward"
        case .habitStack: return "Habit Stack"
        case .completedToday: return "Completed Today"
        case .streak: return "Streak"
        case .totalCompletions: return "Total Completions"
        case .habitTracker: return "Habit Tracker"
        case .buildHabits: return "Build lasting habits, one day at a time 🌱"
        case .todayProgress: return "Today's Progress"
        case .filterByCategory: return "Filter by Category"
        case .allCategories: return "All Categories"
        case .addGoal: return "Add Goal"
        case .goalName: return "Goal Name"
        case .goalDescription: return "Description"
        case .goalCategory: return "Category"
        case .goalDeadline: return "Deadline"
        case .goalProgress: return "Progress"
        case .goalCompleted: return "Completed"
        case .insights: return "Insights"
        case .personalizedTips: return "Personalized Tips"
        case .researchBased: return "Research-Based"
        case .actionableSteps: return "Actionable Steps"
        case .theme: return "Theme"
        case .darkMode: return "Dark Mode"
        case .lightMode: return "Light Mode"
        case .language: return "Language"
        case .account: return "Account"
        case .changeName: return "Change Name"
        case .changePassword: return "Change Password"
        case .privacyPolicy: return "Privacy Policy & Terms of Service"
        case .userGuide: return "User Guide"
        case .quickStart: return "Quick Start"
        case .gettingStarted: return "Getting Started"
        case .getStartedInMinutes: return "Get started in 5 minutes"
        case .welcomeToMonu: return "Welcome to MONU"
        case .mindfulPlanningCompanion: return "Your mindful planning companion"
        case .whatIsMonu: return "What is MONU?"
        case .monuDescription: return "MONU is a mindful planning app designed to help you build lasting habits, achieve your goals, and live with intention. Based on research from books like 'Atomic Habits', 'The Power of Habit', and 'Tiny Habits', MONU combines proven strategies with beautiful design."
        case .keyFeatures: return "Key Features"
        case .dashboardOverview: return "Dashboard Overview"
        case .dashboardDescription: return "Your dashboard provides a comprehensive view of your progress across all areas of your life. It shows completion rates, streaks, and personalized insights to keep you motivated."
        case .dashboardFeatures: return "Dashboard Features"
        case .howToUse: return "How to Use"
        case .howToUseDescription: return "• Check your dashboard daily to see your progress\n• Use the progress cards to understand completion rates\n• Read AI insights for personalized tips\n• Focus on today's tasks for immediate action"
        case .addTask: return "Add Task"
        case .taskTitle: return "Task Title"
        case .dailyPlanTasks: return "Daily Plan Tasks"
        case .yearlyTasks: return "Yearly Tasks"
        case .toDo: return "To Do"
        case .completed: return "Completed"
        case .proTips: return "Pro Tips"
        case .researchBasedFeatures: return "Research-Based Features"
        case .pomodoro: return "Pomodoro"
        case .focus: return "Focus"
        case .shortBreak: return "Short Break"
        case .longBreak: return "Long Break"
        case .start: return "Start"
        case .pause: return "Pause"
        case .reset: return "Reset"
        case .sessionComplete: return "Session Complete"
        }
    }
    
    var chinese: String {
        switch self {
        case .appName: return "MONU"
        case .appTagline: return "转动表盘，调谐时刻"
        case .welcome: return "欢迎"
        case .dashboard: return "仪表板"
        case .habits: return "习惯"
        case .goals: return "目标"
        case .settings: return "设置"
        case .notifications: return "通知"
        case .signOut: return "退出登录"
        case .cancel: return "取消"
        case .save: return "保存"
        case .delete: return "删除"
        case .edit: return "编辑"
        case .done: return "完成"
        case .loading: return "加载中..."
        case .error: return "错误"
        case .success: return "成功"
        case .back: return "返回"
        case .next: return "下一步"
        case .previous: return "上一步"
        case .close: return "关闭"
        case .todayTasks: return "今日任务"
        case .weeklyProgress: return "周进度"
        case .monthlyGoals: return "月目标"
        case .yearlyGoals: return "年目标"
        case .bucketList: return "愿望清单"
        case .futureVision: return "未来愿景"
        case .aiInsights: return "AI洞察"
        case .focusCard: return "专注卡片"
        case .progressCard: return "进度卡片"
        case .progressOverview: return "进度概览"
        case .todaysFocus: return "今日专注"
        case .thisWeek: return "本周"
        case .noTasksToday: return "今天没有任务 ✨"
        case .moreTasks: return "更多"
        case .addHabit: return "添加习惯"
        case .habitName: return "习惯名称"
        case .habitCategory: return "类别"
        case .habitFrequency: return "频率"
        case .habitDifficulty: return "难度"
        case .habitCue: return "触发"
        case .habitReward: return "奖励"
        case .habitStack: return "习惯堆叠"
        case .completedToday: return "今日完成"
        case .streak: return "连续天数"
        case .totalCompletions: return "总完成次数"
        case .habitTracker: return "习惯追踪"
        case .buildHabits: return "建立持久习惯，一天一天来 🌱"
        case .todayProgress: return "今日进度"
        case .filterByCategory: return "按类别筛选"
        case .allCategories: return "所有类别"
        case .addGoal: return "添加目标"
        case .goalName: return "目标名称"
        case .goalDescription: return "描述"
        case .goalCategory: return "类别"
        case .goalDeadline: return "截止日期"
        case .goalProgress: return "进度"
        case .goalCompleted: return "已完成"
        case .insights: return "洞察"
        case .personalizedTips: return "个性化建议"
        case .researchBased: return "基于研究"
        case .actionableSteps: return "可执行步骤"
        case .theme: return "主题"
        case .darkMode: return "深色模式"
        case .lightMode: return "浅色模式"
        case .language: return "语言"
        case .account: return "账户"
        case .changeName: return "修改姓名"
        case .changePassword: return "修改密码"
        case .privacyPolicy: return "隐私政策和服务条款"
        case .userGuide: return "用户指南"
        case .quickStart: return "快速开始"
        case .gettingStarted: return "开始使用"
        case .proTips: return "专业技巧"
        case .researchBasedFeatures: return "基于研究的功能"
        case .pomodoro: return "番茄钟"
        case .focus: return "专注"
        case .shortBreak: return "短休息"
        case .longBreak: return "长休息"
        case .start: return "开始"
        case .pause: return "暂停"
        case .reset: return "重置"
        case .sessionComplete: return "会话完成"
        case .getStartedInMinutes: return "5分钟内开始"
        case .welcomeToMonu: return "欢迎使用MONU"
        case .mindfulPlanningCompanion: return "您的正念规划伙伴"
        case .whatIsMonu: return "什么是MONU？"
        case .monuDescription: return "MONU是一个正念规划应用，旨在帮助您建立持久的习惯，实现目标，并有意地生活。基于《原子习惯》、《习惯的力量》和《微习惯》等书籍的研究，MONU将经过验证的策略与精美设计相结合。"
        case .keyFeatures: return "主要功能"
        case .dashboardOverview: return "仪表板概览"
        case .dashboardDescription: return "您的仪表板提供了生活各个领域进度的全面视图。它显示完成率、连续记录和个性化见解，以保持您的积极性。"
        case .dashboardFeatures: return "仪表板功能"
        case .howToUse: return "如何使用"
        case .howToUseDescription: return "• 每天查看仪表板以了解您的进度\n• 使用进度卡片了解完成率\n• 阅读AI见解获取个性化提示\n• 专注于今天的任务以立即行动"
        case .done: return "完成"
        case .addTask: return "添加任务"
        case .taskTitle: return "任务标题"
        case .dailyPlanTasks: return "每日计划任务"
        case .yearlyTasks: return "年度任务"
        case .toDo: return "待办"
        case .completed: return "已完成"
        }
    }
    
    var spanish: String {
        switch self {
        case .appName: return "MONU"
        case .appTagline: return "Gira los diales, sintoniza el momento"
        case .welcome: return "Bienvenido"
        case .dashboard: return "Panel"
        case .habits: return "Hábitos"
        case .goals: return "Metas"
        case .settings: return "Configuración"
        case .notifications: return "Notificaciones"
        case .signOut: return "Cerrar Sesión"
        case .cancel: return "Cancelar"
        case .save: return "Guardar"
        case .delete: return "Eliminar"
        case .edit: return "Editar"
        case .done: return "Hecho"
        case .loading: return "Cargando..."
        case .error: return "Error"
        case .success: return "Éxito"
        case .back: return "Atrás"
        case .next: return "Siguiente"
        case .previous: return "Anterior"
        case .close: return "Cerrar"
        case .todayTasks: return "Tareas de Hoy"
        case .weeklyProgress: return "Progreso Semanal"
        case .monthlyGoals: return "Metas Mensuales"
        case .yearlyGoals: return "Metas Anuales"
        case .bucketList: return "Lista de Deseos"
        case .futureVision: return "Visión Futura"
        case .aiInsights: return "Insights de IA"
        case .focusCard: return "Tarjeta de Enfoque"
        case .progressCard: return "Tarjeta de Progreso"
        case .progressOverview: return "Resumen de Progreso"
        case .todaysFocus: return "Enfoque de Hoy"
        case .thisWeek: return "Esta Semana"
        case .noTasksToday: return "No hay tareas para hoy ✨"
        case .moreTasks: return "más"
        case .addHabit: return "Agregar Hábito"
        case .habitName: return "Nombre del Hábito"
        case .habitCategory: return "Categoría"
        case .habitFrequency: return "Frecuencia"
        case .habitDifficulty: return "Dificultad"
        case .habitCue: return "Señal"
        case .habitReward: return "Recompensa"
        case .habitStack: return "Apilamiento de Hábitos"
        case .completedToday: return "Completado Hoy"
        case .streak: return "Racha"
        case .totalCompletions: return "Total de Completados"
        case .habitTracker: return "Rastreador de Hábitos"
        case .buildHabits: return "Construye hábitos duraderos, un día a la vez 🌱"
        case .todayProgress: return "Progreso de Hoy"
        case .filterByCategory: return "Filtrar por Categoría"
        case .allCategories: return "Todas las Categorías"
        case .addGoal: return "Agregar Meta"
        case .goalName: return "Nombre de la Meta"
        case .goalDescription: return "Descripción"
        case .goalCategory: return "Categoría"
        case .goalDeadline: return "Fecha Límite"
        case .goalProgress: return "Progreso"
        case .goalCompleted: return "Completado"
        case .insights: return "Insights"
        case .personalizedTips: return "Consejos Personalizados"
        case .researchBased: return "Basado en Investigación"
        case .actionableSteps: return "Pasos Accionables"
        case .theme: return "Tema"
        case .darkMode: return "Modo Oscuro"
        case .lightMode: return "Modo Claro"
        case .language: return "Idioma"
        case .account: return "Cuenta"
        case .changeName: return "Cambiar Nombre"
        case .changePassword: return "Cambiar Contraseña"
        case .privacyPolicy: return "Política de Privacidad y Términos de Servicio"
        case .userGuide: return "Guía de Usuario"
        case .quickStart: return "Inicio Rápido"
        case .gettingStarted: return "Comenzar"
        case .proTips: return "Consejos Pro"
        case .researchBasedFeatures: return "Características Basadas en Investigación"
        case .pomodoro: return "Pomodoro"
        case .focus: return "Enfoque"
        case .shortBreak: return "Descanso Corto"
        case .longBreak: return "Descanso Largo"
        case .start: return "Iniciar"
        case .pause: return "Pausar"
        case .reset: return "Reiniciar"
        case .sessionComplete: return "Sesión Completada"
        case .getStartedInMinutes: return "Comienza en 5 minutos"
        case .welcomeToMonu: return "Bienvenido a MONU"
        case .mindfulPlanningCompanion: return "Tu compañero de planificación consciente"
        case .whatIsMonu: return "¿Qué es MONU?"
        case .monuDescription: return "MONU es una aplicación de planificación consciente diseñada para ayudarte a construir hábitos duraderos, lograr tus metas y vivir con intención. Basado en investigaciones de libros como 'Hábitos Atómicos', 'El Poder del Hábito' y 'Hábitos Minúsculos', MONU combina estrategias probadas con un diseño hermoso."
        case .keyFeatures: return "Características Principales"
        case .dashboardOverview: return "Resumen del Panel"
        case .dashboardDescription: return "Tu panel proporciona una vista integral de tu progreso en todas las áreas de tu vida. Muestra tasas de finalización, rachas y insights personalizados para mantenerte motivado."
        case .dashboardFeatures: return "Características del Panel"
        case .howToUse: return "Cómo Usar"
        case .howToUseDescription: return "• Revisa tu panel diariamente para ver tu progreso\n• Usa las tarjetas de progreso para entender las tasas de finalización\n• Lee los insights de IA para consejos personalizados\n• Enfócate en las tareas de hoy para acción inmediata"
        case .monuDescription: return "MONU es una aplicación de planificación consciente diseñada para ayudarte a construir hábitos duraderos, lograr tus metas y vivir con intención. Basado en investigaciones de libros como 'Hábitos Atómicos', 'El Poder del Hábito' y 'Hábitos Minúsculos', MONU combina estrategias probadas con un diseño hermoso."
        case .keyFeatures: return "Características Principales"
        case .dashboardOverview: return "Resumen del Panel"
        case .dashboardDescription: return "Tu panel proporciona una vista integral de tu progreso en todas las áreas de tu vida. Muestra tasas de finalización, rachas y insights personalizados para mantenerte motivado."
        case .dashboardFeatures: return "Características del Panel"
        case .howToUse: return "Cómo Usar"
        case .howToUseDescription: return "• Revisa tu panel diariamente para ver tu progreso\n• Usa las tarjetas de progreso para entender las tasas de finalización\n• Lee los insights de IA para consejos personalizados\n• Enfócate en las tareas de hoy para acción inmediata"
        case .done: return "Hecho"
        case .addTask: return "Agregar Tarea"
        case .taskTitle: return "Título de la Tarea"
        case .dailyPlanTasks: return "Tareas del Plan Diario"
        case .yearlyTasks: return "Tareas Anuales"
        case .toDo: return "Por Hacer"
        case .completed: return "Completado"
        }
    }
}

 