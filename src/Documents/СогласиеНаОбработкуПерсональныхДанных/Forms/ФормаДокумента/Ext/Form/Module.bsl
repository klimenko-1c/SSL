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
	
	Если Параметры.Свойство("АвтоТест") Тогда // Возврат при получении формы для анализа.
		Возврат;
	КонецЕсли;
	
	Если Параметры.Ключ.Пустая() Тогда
		// Заполняем значениями по умолчанию.
		Объект.Ответственный = Пользователи.ТекущийПользователь();
		Если Не Параметры.Свойство("ДатаСогласия", Объект.ДатаПолучения) Тогда
			Объект.ДатаПолучения = ТекущаяДатаСеанса();
		КонецЕсли;
		Если Не Параметры.Свойство("Организация", Объект.Организация) Тогда
			Если Не Метаданные.ОпределяемыеТипы.Организация.Тип.СодержитТип(Тип("Строка")) Тогда
				ПолноеИмя = Метаданные.НайтиПоТипу(Метаданные.ОпределяемыеТипы.Организация.Тип.Типы()[0]).ПолноеИмя();
				ИмяСправочникаОрганизации = "Справочники." + СтрРазделить(ПолноеИмя, ".")[1];
				МодульОрганизации = ОбщегоНазначения.ОбщийМодуль(ИмяСправочникаОрганизации);
				Объект.Организация = МодульОрганизации.ОрганизацияПоУмолчанию();
			КонецЕсли;
		КонецЕсли;
		ЗаполнитьДанныеОрганизации();
		Если Параметры.Свойство("Субъект") Тогда
			Объект.Субъект = Параметры.Субъект;
			ЗаполнитьДанныеСубъекта();
		КонецЕсли;
		УстановитьСведенияДействующегоСогласия();
	КонецЕсли;
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКоманды.ПриСозданииНаСервере(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКомандыКлиент.НачатьОбновлениеКоманд(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	УстановитьСведенияДействующегоСогласия();
	
	// СтандартныеПодсистемы.ДатыЗапретаИзменения
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ДатыЗапретаИзменения") Тогда
		МодульДатыЗапретаИзменения = ОбщегоНазначения.ОбщийМодуль("ДатыЗапретаИзменения");
		МодульДатыЗапретаИзменения.ОбъектПриЧтенииНаСервере(ЭтотОбъект, ТекущийОбъект);
	КонецЕсли;
	// Конец СтандартныеПодсистемы.ДатыЗапретаИзменения
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Объект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
	// СтандартныеПодсистемы.УправлениеДоступом
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.УправлениеДоступом") Тогда
		МодульУправлениеДоступом = ОбщегоНазначения.ОбщийМодуль("УправлениеДоступом");
		МодульУправлениеДоступом.ПриЧтенииНаСервере(ЭтотОбъект, ТекущийОбъект);
	КонецЕсли;
	// Конец СтандартныеПодсистемы.УправлениеДоступом
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	
	Оповестить("ИзмененаДатаСкрытияПерсональныхДанных");
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ОрганизацияПриИзменении(Элемент)
	
	ОрганизацияПриИзмененииНаСервере();
	
КонецПроцедуры

&НаКлиенте
Процедура ОтветственныйЗаОбработкуПерсональныхДанныхПриИзменении(Элемент)
	
	ОтветственныйЗаПДнПриИзмененииНаСервере();
	
КонецПроцедуры

&НаКлиенте
Процедура СубъектПриИзменении(Элемент)
	
	СубъектПриИзмененииНаСервере();
	
КонецПроцедуры

&НаКлиенте
Процедура ДатаПолученияПриИзменении(Элемент)
	
	ДатаПолученияПриИзмененииНаСервере();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

// СтандартныеПодсистемы.ПодключаемыеКоманды
&НаКлиенте
Процедура Подключаемый_ВыполнитьКоманду(Команда)
	ПодключаемыеКомандыКлиент.ВыполнитьКоманду(ЭтотОбъект, Команда, Объект);
КонецПроцедуры

&НаСервере
Процедура Подключаемый_ВыполнитьКомандуНаСервере(Контекст, Результат)
	ПодключаемыеКоманды.ВыполнитьКоманду(ЭтотОбъект, Контекст, Объект, Результат);
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ОбновитьКоманды()
	ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Объект);
КонецПроцедуры
// Конец СтандартныеПодсистемы.ПодключаемыеКоманды

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ОрганизацияПриИзмененииНаСервере()
	
	ЗаполнитьДанныеОрганизации();
	УстановитьСведенияДействующегоСогласия();
	
КонецПроцедуры

&НаСервере
Процедура ОтветственныйЗаПДнПриИзмененииНаСервере()
	
	Объект.ФИООтветственногоЗаОбработкуПДн = Неопределено;
	
	Если Не ЗначениеЗаполнено(Объект.ОтветственныйЗаОбработкуПерсональныхДанных) Тогда
		Возврат;
	КонецЕсли;
	
	ОтветственныйФизическоеЛицо = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Объект.ОтветственныйЗаОбработкуПерсональныхДанных, "ФизическоеЛицо");
	ЗащитаПерсональныхДанныхПереопределяемый.ЗаполнитьФИОФизическогоЛица(ОтветственныйФизическоеЛицо, Объект.ФИООтветственногоЗаОбработкуПДн);
	
КонецПроцедуры

&НаСервере
Процедура СубъектПриИзмененииНаСервере()
	
	ЗаполнитьДанныеСубъекта();
	УстановитьСведенияДействующегоСогласия();
	
КонецПроцедуры

&НаСервере
Процедура ДатаПолученияПриИзмененииНаСервере()
	
	УстановитьСведенияДействующегоСогласия();
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьДанныеОрганизации()
	
	ДанныеОрганизации = ЗащитаПерсональныхДанных.ОписаниеДанныхОрганизации();
	
	ЗащитаПерсональныхДанныхПереопределяемый.ДополнитьДанныеОрганизацииОператораПерсональныхДанных(Объект.Организация, ДанныеОрганизации, Объект.ДатаПолучения);
	
	Объект.НаименованиеОрганизации = ДанныеОрганизации.НаименованиеОрганизации;
	Объект.ЮридическийАдресОрганизации = ДанныеОрганизации.АдресОрганизации;
	Объект.ОтветственныйЗаОбработкуПерсональныхДанных = ДанныеОрганизации.ОтветственныйЗаОбработкуПерсональныхДанных;
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьДанныеСубъекта()
	
	ДанныеСубъекта = ЗащитаПерсональныхДанных.ОписаниеДанныхСубъекта();		
	ДанныеСубъекта.Субъект = Объект.Субъект;
	
	ДанныеСубъектов = Новый Массив;
	ДанныеСубъектов.Добавить(ДанныеСубъекта);
		
	ЗащитаПерсональныхДанныхПереопределяемый.ДополнитьДанныеСубъектовПерсональныхДанных(ДанныеСубъектов, Объект.ДатаПолучения);
	
	Объект.ФИОСубъекта = ДанныеСубъекта.ФИО;
	Объект.АдресСубъекта = ДанныеСубъекта.Адрес;
	Объект.ПаспортныеДанные = ДанныеСубъекта.ПаспортныеДанные;
	
КонецПроцедуры

&НаСервере
Процедура УстановитьСведенияДействующегоСогласия()
	
	// Запрашиваем сведения о действующем согласии.
	Согласие = ЗащитаПерсональныхДанных.ДействующееСогласиеНаОбработкуПерсональныхДанных(Объект.Субъект, Объект.Организация, Объект.ДатаПолучения, Объект.Ссылка);
	
	Если Согласие = Неопределено Тогда
		// Не обнаружено действующего согласия - не отображаем сведения.
		Элементы.СведенияОСогласииГруппа.Видимость = Ложь;
		Возврат;
	КонецЕсли;
	
	// Обнаружено действующее согласие.
	Элементы.СведенияОСогласииГруппа.Видимость = Истина;
	
	// Пример сообщения: "У субъекта 20.03.2014 уже было получено согласие, которое действует до 20.03.2017".
	ЧастиСообщения = Новый Массив;
	ЧастиСообщения.Добавить(СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'У субъекта %1 уже было получено'"), Формат(Согласие.ДатаПолучения, "ДЛФ=D")) + " ");
	ЧастиСообщения.Добавить(Новый ФорматированнаяСтрока(НСтр("ru = 'согласие'"), , , , ПолучитьНавигационнуюСсылку(Согласие.ДокументОснование)));
	Если ЗначениеЗаполнено(Согласие.СрокДействия) Тогда
		ЧастиСообщения.Добавить(СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = ', которое действует до %1.'"), Формат(Согласие.СрокДействия, "ДЛФ=D")));
	Иначе	
		ЧастиСообщения.Добавить(НСтр("ru = ', которое действует бессрочно.'"));
	КонецЕсли;
	
	Элементы.ПредупреждениеТекст.Заголовок = Новый ФорматированнаяСтрока(ЧастиСообщения);
	
КонецПроцедуры

#КонецОбласти
