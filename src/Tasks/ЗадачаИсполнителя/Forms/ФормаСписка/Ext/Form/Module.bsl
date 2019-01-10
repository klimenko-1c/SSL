﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2018, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	УстановитьУсловноеОформление();
	
	Если Параметры.Свойство("АвтоТест") Тогда // Возврат при получении формы для анализа.
		Возврат;
	КонецЕсли;
	
	ТекстЗаголовкаФормы = "";
	Если Параметры.Свойство("ЗаголовокФормы", ТекстЗаголовкаФормы) 
		И Не ПустаяСтрока(ТекстЗаголовкаФормы) Тогда
		Заголовок = ТекстЗаголовкаФормы;
		АвтоЗаголовок = Ложь;
	КонецЕсли;
	
	Если Параметры.Свойство("БизнесПроцесс") Тогда
		СтрокаБизнесПроцесса = Параметры.БизнесПроцесс;
		СтрокаЗадачи = Параметры.Задача;
		Элементы.ГруппаЗаголовок.Видимость = Истина;
	КонецЕсли;
	
	Если Параметры.Свойство("ПоказыватьЗадачи") Тогда
		ПоказыватьЗадачи = Параметры.ПоказыватьЗадачи;
	Иначе
		ПоказыватьЗадачи = 2;
	КонецЕсли;
	
	Если Параметры.Свойство("ВидимостьОтборов") Тогда
		Элементы.ГруппаОтбор.Видимость = Параметры.ВидимостьОтборов;
	Иначе
		ПоАвтору = Пользователи.АвторизованныйПользователь();
	КонецЕсли;
	УстановитьОтбор();
	
	Если Параметры.Свойство("БлокировкаОкнаВладельца") Тогда
		РежимОткрытияОкна = Параметры.БлокировкаОкнаВладельца;
	КонецЕсли;
		
	ИспользоватьДатуИВремяВСрокахЗадач = ПолучитьФункциональнуюОпцию("ИспользоватьДатуИВремяВСрокахЗадач");
	Элементы.СрокИсполнения.Формат = ?(ИспользоватьДатуИВремяВСрокахЗадач, "ДЛФ=DT", "ДЛФ=D");
	Элементы.ДатаИсполнения.Формат = ?(ИспользоватьДатуИВремяВСрокахЗадач, "ДЛФ=DT", "ДЛФ=D");
	
	Если Пользователи.ЭтоСеансВнешнегоПользователя() Тогда
		Элементы.ПоАвтору.Видимость = Ложь;
		Элементы.ПоИсполнителю.Видимость = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия = "Запись_ЗадачаИсполнителя" Тогда
		ОбновитьСписокЗадачНаСервере();
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПередЗагрузкойДанныхИзНастроекНаСервере(Настройки)

	ИмяНастройки = ?(Параметры.Свойство("БизнесПроцесс"), "ФормаСпискаБП", "ФормаСписка");
	НастройкиОтбора = ОбщегоНазначения.ХранилищеСистемныхНастроекЗагрузить("Задачи.ЗадачаИсполнителя.Формы.ФормаСписка", ИмяНастройки);
	Если НастройкиОтбора = Неопределено Тогда 
		Настройки.Очистить();
		Возврат;
	КонецЕсли;
	
	Для Каждого Элемент Из НастройкиОтбора Цикл
		Настройки.Вставить(Элемент.Ключ, Элемент.Значение);
	КонецЦикла;
	УстановитьОтборСписка(Список, НастройкиОтбора);
	
КонецПроцедуры

&НаСервере
Процедура ПриСохраненииДанныхВНастройкахНаСервере(Настройки)
	ИмяНастроек = ?(Элементы.ГруппаЗаголовок.Видимость, "ФормаСпискаБП", "ФормаСписка");
	ОбщегоНазначения.ХранилищеСистемныхНастроекСохранить("Задачи.ЗадачаИсполнителя.Формы.ФормаСписка", ИмяНастроек, Настройки);
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаПерехода(ОбъектПерехода, СтандартнаяОбработка)
	
	Если Не ЗначениеЗаполнено(ОбъектПерехода) Или ОбъектПерехода = Элементы.Список.ТекущаяСтрока Тогда
		Возврат;
	КонецЕсли;
	
	ПоАвтору = Неопределено;
	ПоИсполнителю = Неопределено;
	ПоказыватьЗадачи = 0;
	УстановитьОтбор();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ПоИсполнителюПриИзменении(Элемент)
	УстановитьОтбор();
КонецПроцедуры

&НаКлиенте
Процедура ПоАвторуПриИзменении(Элемент)
	УстановитьОтбор();
КонецПроцедуры

&НаКлиенте
Процедура ПоказыватьЗадачиПриИзменении(Элемент)
	УстановитьОтбор();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыСписок

&НаКлиенте
Процедура СписокПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа)
	
	БизнесПроцессыИЗадачиКлиент.СписокЗадачПередНачаломДобавления(ЭтотОбъект, Элемент, Отказ, Копирование, 
		Родитель, Группа);
	
КонецПроцедуры

&НаКлиенте
Процедура СписокПриАктивизацииСтроки(Элемент)
	Если Элемент.ТекущиеДанные <> Неопределено
		И Элемент.ТекущиеДанные.Свойство("ПринятаКИсполнению")
		И НЕ Элемент.ТекущиеДанные.ПринятаКИсполнению Тогда
			Элементы.ПринятьКИсполнению.Доступность= Истина;
	Иначе
			Элементы.ПринятьКИсполнению.Доступность= Ложь;
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ПринятьКИсполнению(Команда)
	
	БизнесПроцессыИЗадачиКлиент.ПринятьЗадачиКИсполнению(Элементы.Список.ВыделенныеСтроки);
	
КонецПроцедуры

&НаКлиенте
Процедура ОтменитьПринятиеКИсполнению(Команда)
	
	БизнесПроцессыИЗадачиКлиент.ОтменитьПринятиеЗадачКИсполнению(Элементы.Список.ВыделенныеСтроки);
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьСписокЗадач(Команда)
	
	ОбновитьСписокЗадачНаСервере();
	
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьБизнесПроцесс(Команда)
	Если ТипЗнч(Элементы.Список.ТекущаяСтрока) <> Тип("ЗадачаСсылка.ЗадачаИсполнителя") Тогда
		ПоказатьПредупреждение(,НСтр("ru = 'Команда не может быть выполнена для указанного объекта.'"));
		Возврат;
	КонецЕсли;
	Если Элементы.Список.ТекущиеДанные.БизнесПроцесс = Неопределено Тогда
		ПоказатьПредупреждение(,НСтр("ru = 'У выбранной задачи не указан бизнес-процесс.'"));
		Возврат;
	КонецЕсли;
	ПоказатьЗначение(, Элементы.Список.ТекущиеДанные.БизнесПроцесс);
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьПредметЗадачи(Команда)
	Если ТипЗнч(Элементы.Список.ТекущаяСтрока) <> Тип("ЗадачаСсылка.ЗадачаИсполнителя") Тогда
		ПоказатьПредупреждение(,НСтр("ru = 'Команда не может быть выполнена для указанного объекта.'"));
		Возврат;
	КонецЕсли;
	Если Элементы.Список.ТекущиеДанные.Предмет = Неопределено Тогда
		ПоказатьПредупреждение(,НСтр("ru = 'У выбранной задачи не указан предмет.'"));
		Возврат;
	КонецЕсли;
	ПоказатьЗначение(, Элементы.Список.ТекущиеДанные.Предмет);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура УстановитьОтбор()
	
	ПараметрыОтбора = Новый Соответствие();
	ПараметрыОтбора.Вставить("ПоАвтору", ПоАвтору);
	ПараметрыОтбора.Вставить("ПоИсполнителю", ПоИсполнителю);
	ПараметрыОтбора.Вставить("ПоказыватьЗадачи", ПоказыватьЗадачи);
	УстановитьОтборСписка(Список, ПараметрыОтбора);
	
КонецПроцедуры	

&НаСервереБезКонтекста
Процедура УстановитьОтборСписка(Список, ПараметрыОтбора)
	
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
		Список, "Автор", ПараметрыОтбора["ПоАвтору"],,, ПараметрыОтбора["ПоАвтору"] <> Неопределено И Не ПараметрыОтбора["ПоАвтору"].Пустая());
	
	Если ПараметрыОтбора["ПоИсполнителю"] = Неопределено Или ПараметрыОтбора["ПоИсполнителю"].Пустая() Тогда
		Список.Параметры.УстановитьЗначениеПараметра("ВыбранныйИсполнитель", NULL);
	Иначе	
		Список.Параметры.УстановитьЗначениеПараметра("ВыбранныйИсполнитель", ПараметрыОтбора["ПоИсполнителю"]);
	КонецЕсли;
		
	Если ПараметрыОтбора["ПоказыватьЗадачи"] = 0 Тогда 
		ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
			Список, "Выполнена", Истина,,,Ложь);
	ИначеЕсли ПараметрыОтбора["ПоказыватьЗадачи"] = 1 Тогда
		ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
			Список, "Выполнена", Истина,,,Истина);
	ИначеЕсли ПараметрыОтбора["ПоказыватьЗадачи"] = 2 Тогда
		ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
			Список, "Выполнена", Ложь,,,Истина);
	КонецЕсли;	
	
КонецПроцедуры

&НаСервере
Процедура УстановитьУсловноеОформление()
	
	БизнесПроцессыИЗадачиСервер.УстановитьОформлениеЗадач(Список);
	
КонецПроцедуры

&НаСервере
Процедура ОбновитьСписокЗадачНаСервере()
	
	БизнесПроцессыИЗадачиСервер.УстановитьОформлениеЗадач(Список);
	// Цвет просроченных задач зависит от значения текущей даты,
	// поэтому нужно переинициализировать условное оформление.
	УстановитьУсловноеОформление();
	Элементы.Список.Обновить();
	
КонецПроцедуры

#КонецОбласти
