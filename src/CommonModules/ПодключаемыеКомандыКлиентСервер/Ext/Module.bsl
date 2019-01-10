﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2018, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Обновляет список команд в зависимости от текущего контекста.
//
// Параметры:
//   Форма - УправляемаяФорма - форма, для которой требуется обновление команд.
//   Источник - ДанныеФормыСтруктура, ТаблицаФормы - контекст для проверки условий (Форма.Объект или Форма.Элементы.Список).
//
Процедура ОбновитьКоманды(Форма, Источник) Экспорт
	Структура = Новый Структура("ПараметрыПодключаемыхКоманд", Null);
	ЗаполнитьЗначенияСвойств(Структура, Форма);
	ПараметрыКлиента = Структура.ПараметрыПодключаемыхКоманд;
	Если ТипЗнч(ПараметрыКлиента) <> Тип("Структура") Тогда
		Возврат;
	КонецЕсли;
	
	Если ТипЗнч(Источник) = Тип("ТаблицаФормы") Тогда
		ДоступностьКоманд = (Источник.ТекущаяСтрока <> Неопределено);
	Иначе
		ДоступностьКоманд = Истина;
	КонецЕсли;
	Если ДоступностьКоманд <> ПараметрыКлиента.ДоступностьКоманд Тогда
		ПараметрыКлиента.ДоступностьКоманд = ДоступностьКоманд;
		Для Каждого ИмяКнопкиИлиПодменю Из ПараметрыКлиента.КорневыеПодменюИКоманды Цикл
			КнопкаИлиПодменю = Форма.Элементы[ИмяКнопкиИлиПодменю];
			КнопкаИлиПодменю.Доступность = ДоступностьКоманд;
			Если ТипЗнч(КнопкаИлиПодменю) = Тип("ГруппаФормы") И КнопкаИлиПодменю.Вид = ВидГруппыФормы.Подменю Тогда
				СкрытьПоказатьВсеПодчиненныеКнопки(КнопкаИлиПодменю, ДоступностьКоманд);
				КомандаЗаглушка = Форма.Элементы.Найти(ИмяКнопкиИлиПодменю + "Заглушка");
				Если КомандаЗаглушка <> Неопределено Тогда
					КомандаЗаглушка.Видимость = Не ДоступностьКоманд;
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	Если Не ДоступностьКоманд Или Не ПараметрыКлиента.ЕстьУсловияВидимости Тогда
		Возврат;
	КонецЕсли;
	
	ВыбранныеОбъекты = Новый Массив;
	ПроверятьОписаниеТипов = Ложь;
	
	Если ТипЗнч(Источник) = Тип("ТаблицаФормы") Тогда
		ВыделенныеСтроки = Источник.ВыделенныеСтроки;
		Для Каждого ВыделеннаяСтрока Из ВыделенныеСтроки Цикл
			Если ТипЗнч(ВыделеннаяСтрока) = Тип("СтрокаГруппировкиДинамическогоСписка") Тогда
				Продолжить;
			КонецЕсли;
			ТекущаяСтрока = Источник.ДанныеСтроки(ВыделеннаяСтрока);
			Если ТекущаяСтрока <> Неопределено Тогда
				ВыбранныеОбъекты.Добавить(ТекущаяСтрока);
			КонецЕсли;
		КонецЦикла;
		ПроверятьОписаниеТипов = Истина;
	Иначе
		ВыбранныеОбъекты.Добавить(Источник);
	КонецЕсли;
	
	Для Каждого КраткиеСведенияОПодменю Из ПараметрыКлиента.ПодменюСУсловиямиВидимости Цикл
		ЕстьВидимыеКоманды = Ложь;
		Подменю = Форма.Элементы.Найти(КраткиеСведенияОПодменю.Имя);
		ИзменятьВидимость = (ТипЗнч(Подменю) = Тип("ГруппаФормы") И Подменю.Вид = ВидГруппыФормы.Подменю);
		
		Для Каждого Команда Из КраткиеСведенияОПодменю.КомандыСУсловиямиВидимости Цикл
			КомандаЭлемент = Форма.Элементы[Команда.ИмяВФорме];
			Видимость = Истина;
			Для Каждого Объект Из ВыбранныеОбъекты Цикл
				Если ПроверятьОписаниеТипов
					И ТипЗнч(Команда.ТипПараметра) = Тип("ОписаниеТипов")
					И Не Команда.ТипПараметра.СодержитТип(ТипЗнч(Объект.Ссылка)) Тогда
					Видимость = Ложь;
					Прервать;
				КонецЕсли;
				Если ТипЗнч(Команда.УсловияВидимости) = Тип("Массив")
					И Не УсловияВыполняются(Команда.УсловияВидимости, Объект) Тогда
					Видимость = Ложь;
					Прервать;
				КонецЕсли;
			КонецЦикла;
			Если ИзменятьВидимость Тогда
				КомандаЭлемент.Видимость = Видимость;
			Иначе
				КомандаЭлемент.Доступность = Видимость;
			КонецЕсли;
			ЕстьВидимыеКоманды = ЕстьВидимыеКоманды Или Видимость;
		КонецЦикла;
		
		Если Не КраткиеСведенияОПодменю.ЕстьКомандыБезУсловийВидимости Тогда
			КомандаЗаглушка = Форма.Элементы.Найти(КраткиеСведенияОПодменю.Имя + "Заглушка");
			Если КомандаЗаглушка <> Неопределено Тогда
				КомандаЗаглушка.Видимость = Не ЕстьВидимыеКоманды;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Шаблон второго параметра обработчика команды.
//
// Возвращаемое значение:
//   Структура - Вспомогательные параметры.
//       * ОписаниеКоманды - Структура - Описание команды.
//           Структура аналогична таблице ПодключаемыеКоманды.ТаблицаКоманд().
//           ** Идентификатор - Строка - Идентификатор команды.
//           ** Представление - Строка - Представление команды в форме.
//           ** ДополнительныеПараметры - Структура - Дополнительные параметры команды.
//       * Форма - УправляемаяФорма - Форма, из которой вызвана команда.
//       * ЭтоФормаОбъекта - Булево - Истина, если команда вызвана из формы объекта.
//       * Источник - ТаблицаФормы, ДанныеФормыСтруктура - Объект или список формы с полем "Ссылка".
//
Функция ШаблонПараметровВыполненияКоманды() Экспорт
	Структура = Новый Структура("ОписаниеКоманды, Форма, Источник");
	Структура.Вставить("ЭтоФормаОбъекта", Ложь);
	Возврат Структура;
КонецФункции

Функция УсловияВыполняются(Условия, ЗначенияРеквизитов)
	Для Каждого Условие Из Условия Цикл
		ИмяРеквизита = Условие.Реквизит;
		Если Не ЗначенияРеквизитов.Свойство(ИмяРеквизита) Тогда
			Продолжить;
		КонецЕсли;
		УсловиеВыполняется = Истина;
		Если Условие.ВидСравнения = ВидСравнения.Равно
			Или Условие.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно Тогда
			УсловиеВыполняется = ЗначенияРеквизитов[ИмяРеквизита] = Условие.Значение;
		ИначеЕсли Условие.ВидСравнения = ВидСравнения.Больше
			Или Условие.ВидСравнения = ВидСравненияКомпоновкиДанных.Больше Тогда
			УсловиеВыполняется = ЗначенияРеквизитов[ИмяРеквизита] > Условие.Значение;
		ИначеЕсли Условие.ВидСравнения = ВидСравнения.БольшеИлиРавно
			Или Условие.ВидСравнения = ВидСравненияКомпоновкиДанных.БольшеИлиРавно Тогда
			УсловиеВыполняется = ЗначенияРеквизитов[ИмяРеквизита] >= Условие.Значение;
		ИначеЕсли Условие.ВидСравнения = ВидСравнения.Меньше
			Или Условие.ВидСравнения = ВидСравненияКомпоновкиДанных.Меньше Тогда
			УсловиеВыполняется = ЗначенияРеквизитов[ИмяРеквизита] < Условие.Значение;
		ИначеЕсли Условие.ВидСравнения = ВидСравнения.МеньшеИлиРавно
			Или Условие.ВидСравнения = ВидСравненияКомпоновкиДанных.МеньшеИлиРавно Тогда
			УсловиеВыполняется = ЗначенияРеквизитов[ИмяРеквизита] <= Условие.Значение;
		ИначеЕсли Условие.ВидСравнения = ВидСравнения.НеРавно
			Или Условие.ВидСравнения = ВидСравненияКомпоновкиДанных.НеРавно Тогда
			УсловиеВыполняется = ЗначенияРеквизитов[ИмяРеквизита] <> Условие.Значение;
		ИначеЕсли Условие.ВидСравнения = ВидСравнения.ВСписке
			Или Условие.ВидСравнения = ВидСравненияКомпоновкиДанных.ВСписке Тогда
			УсловиеВыполняется = Условие.Значение.Найти(ЗначенияРеквизитов[ИмяРеквизита]) <> Неопределено;
		ИначеЕсли Условие.ВидСравнения = ВидСравнения.НеВСписке
			Или Условие.ВидСравнения = ВидСравненияКомпоновкиДанных.НеВСписке Тогда
			УсловиеВыполняется = Условие.Значение.Найти(ЗначенияРеквизитов[ИмяРеквизита]) = Неопределено;
		ИначеЕсли Условие.ВидСравнения = ВидСравненияКомпоновкиДанных.Заполнено Тогда
			УсловиеВыполняется = ЗначениеЗаполнено(ЗначенияРеквизитов[ИмяРеквизита]);
		ИначеЕсли Условие.ВидСравнения = ВидСравненияКомпоновкиДанных.НеЗаполнено Тогда
			УсловиеВыполняется = Не ЗначениеЗаполнено(ЗначенияРеквизитов[ИмяРеквизита]);
		КонецЕсли;
		Если Не УсловиеВыполняется Тогда
			Возврат Ложь;
		КонецЕсли;
	КонецЦикла;
	Возврат Истина;
КонецФункции

Процедура СкрытьПоказатьВсеПодчиненныеКнопки(ГруппаФормы, Видимость)
	Для Каждого ПодчиненныйЭлемент Из ГруппаФормы.ПодчиненныеЭлементы Цикл
		Если ТипЗнч(ПодчиненныйЭлемент) = Тип("ГруппаФормы") Тогда
			СкрытьПоказатьВсеПодчиненныеКнопки(ПодчиненныйЭлемент, Видимость);
		ИначеЕсли ТипЗнч(ПодчиненныйЭлемент) = Тип("КнопкаФормы") Тогда
			ПодчиненныйЭлемент.Видимость = Видимость;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

#КонецОбласти