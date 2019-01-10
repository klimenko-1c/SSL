﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2018, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

#Область ДляВызоваИзДругихПодсистем

// СтандартныеПодсистемы.ГрупповоеИзменениеОбъектов

// Возвращает реквизиты объекта, которые разрешается редактировать
// с помощью обработки группового изменения реквизитов.
//
// Возвращаемое значение:
//  Массив - список имен реквизитов объекта.
Функция РеквизитыРедактируемыеВГрупповойОбработке() Экспорт
	
	Результат = Новый Массив;
	Результат.Добавить("Важность");
	Результат.Добавить("Ответственный");
	Результат.Добавить("ВзаимодействиеОснование");
	Результат.Добавить("Комментарий");
	Результат.Добавить("ОтправительКонтакт");
	Результат.Добавить("ОтправительПредставление");
	Результат.Добавить("ПолучателиПисьма.Представление");
	Результат.Добавить("ПолучателиПисьма.Контакт");
	Результат.Добавить("ПолучателиКопий.Представление");
	Результат.Добавить("ПолучателиКопий.Контакт");
	Результат.Добавить("ПолучателиОтвета.Представление");
	Результат.Добавить("ПолучателиОтвета.Контакт");
	Результат.Добавить("АдресаУведомленияОПрочтении.Представление");
	Результат.Добавить("АдресаУведомленияОПрочтении.Контакт");
	Возврат Результат;
	
КонецФункции

// Конец СтандартныеПодсистемы.ГрупповоеИзменениеОбъектов

// СтандартныеПодсистемы.Взаимодействия

// Получает отправителя и адресатов электронного письма.
//
// Параметры:
//  Ссылка  - ДокументСсылка.ЭлектронноеПисьмоВходящее - документ, абонента которого необходимо получить.
//
// Возвращаемое значение:
//   ТаблицаЗначений   - таблица, содержащая колонки "Контакт", "Представление" и "Адрес".
//
Функция ПолучитьКонтакты(Ссылка) Экспорт

	ТекстЗапроса = 
		"ВЫБРАТЬ
		|	ЭлектронноеПисьмоВходящее.УчетнаяЗапись.АдресЭлектроннойПочты
		|ПОМЕСТИТЬ НашАдрес
		|ИЗ
		|	Документ.ЭлектронноеПисьмоВходящее КАК ЭлектронноеПисьмоВходящее
		|ГДЕ
		|	ЭлектронноеПисьмоВходящее.Ссылка = &Ссылка
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ЭлектронноеПисьмоВходящее.ОтправительАдрес КАК Адрес,
		|	ПОДСТРОКА(ЭлектронноеПисьмоВходящее.ОтправительПредставление, 1, 1000) КАК Представление,
		|	ЭлектронноеПисьмоВходящее.ОтправительКонтакт КАК Контакт
		|ПОМЕСТИТЬ ВсеКонтакты
		|ИЗ
		|	Документ.ЭлектронноеПисьмоВходящее КАК ЭлектронноеПисьмоВходящее
		|ГДЕ
		|	ЭлектронноеПисьмоВходящее.Ссылка = &Ссылка
		|
		|ОБЪЕДИНИТЬ
		|
		|ВЫБРАТЬ
		|	ЭлектронноеПисьмоВходящееПолучателиПисьма.Адрес,
		|	ЭлектронноеПисьмоВходящееПолучателиПисьма.Представление,
		|	ЭлектронноеПисьмоВходящееПолучателиПисьма.Контакт
		|ИЗ
		|	Документ.ЭлектронноеПисьмоВходящее.ПолучателиПисьма КАК ЭлектронноеПисьмоВходящееПолучателиПисьма
		|ГДЕ
		|	ЭлектронноеПисьмоВходящееПолучателиПисьма.Ссылка = &Ссылка
		|
		|ОБЪЕДИНИТЬ
		|
		|ВЫБРАТЬ
		|	ЭлектронноеПисьмоВходящееПолучателиКопий.Адрес,
		|	ЭлектронноеПисьмоВходящееПолучателиКопий.Представление,
		|	ЭлектронноеПисьмоВходящееПолучателиКопий.Контакт
		|ИЗ
		|	Документ.ЭлектронноеПисьмоВходящее.ПолучателиКопий КАК ЭлектронноеПисьмоВходящееПолучателиКопий
		|ГДЕ
		|	ЭлектронноеПисьмоВходящееПолучателиКопий.Ссылка = &Ссылка
		|
		|ОБЪЕДИНИТЬ
		|
		|ВЫБРАТЬ
		|	ЭлектронноеПисьмоВходящееПолучателиОтвета.Адрес,
		|	ЭлектронноеПисьмоВходящееПолучателиОтвета.Представление,
		|	ЭлектронноеПисьмоВходящееПолучателиОтвета.Контакт
		|ИЗ
		|	Документ.ЭлектронноеПисьмоВходящее.ПолучателиОтвета КАК ЭлектронноеПисьмоВходящееПолучателиОтвета
		|ГДЕ
		|	ЭлектронноеПисьмоВходящееПолучателиОтвета.Ссылка = &Ссылка
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВсеКонтакты.Адрес,
		|	ВсеКонтакты.Представление,
		|	ВсеКонтакты.Контакт
		|ИЗ
		|	ВсеКонтакты КАК ВсеКонтакты
		|		ЛЕВОЕ СОЕДИНЕНИЕ НашАдрес КАК НашАдрес
		|		ПО (ВсеКонтакты.Адрес = НашАдрес.УчетнаяЗаписьАдресЭлектроннойПочты)
		|ГДЕ
		|	НашАдрес.УчетнаяЗаписьАдресЭлектроннойПочты ЕСТЬ NULL ";

	Запрос = Новый Запрос;
	Запрос.Текст = ТекстЗапроса;
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	ТаблицаКонтактов = Запрос.Выполнить().Выгрузить();

	Возврат Взаимодействия.ПреобразоватьТаблицуКонтактовВМассив(ТаблицаКонтактов);
	
КонецФункции

// Конец СтандартныеПодсистемы.Взаимодействия

// СтандартныеПодсистемы.УправлениеДоступом

// См. УправлениеДоступомПереопределяемый.ПриЗаполненииСписковСОграничениемДоступа.
Процедура ПриЗаполненииОграниченияДоступа(Ограничение) Экспорт
	
	Ограничение.Текст =
	"РазрешитьЧтениеИзменение
	|ГДЕ
	|	ЗначениеРазрешено(Ответственный, Отключено КАК Ложь)
	|	ИЛИ ЗначениеРазрешено(УчетнаяЗапись, Отключено КАК Ложь)";
	
КонецПроцедуры

// Конец СтандартныеПодсистемы.УправлениеДоступом

#КонецОбласти

#КонецОбласти

#Область ОбработчикиСобытий

Процедура ОбработкаПолученияДанныхВыбора(ДанныеВыбора, Параметры, СтандартнаяОбработка)
	
	ВзаимодействияСобытия.ОбработкаПолученияДанныхВыбора(Метаданные.Документы.ЭлектронноеПисьмоВходящее.Имя,
		ДанныеВыбора, Параметры, СтандартнаяОбработка);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Область ОбработчикиОбновления

// Регистрирует к обработке электронные письма у которых возможно заполнить ВзаимодействиеОснование.
//
Процедура ЗаполнитьВзаимодействияОснованияУПодчиненныхПисемКОбработке(Параметры) Экспорт

	Запрос = Новый Запрос;
	Запрос.Текст = Взаимодействия.ТекстЗапросаОтметкиКОбработкиЗаполненияПисемОснований("Документ.ЭлектронноеПисьмоВходящее");
	
	ОбновлениеИнформационнойБазы.ОтметитьКОбработке(
		Параметры,
		Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Ссылка"));

КонецПроцедуры 

// Выполняет дозаполнение реквизита ВзаимодействиеОснование у электронных писем.
//
Процедура ЗаполнитьВзаимодействияОснованияУПодчиненныхПисем(Параметры) Экспорт
	
	ПолноеИмяДокумента = "Документ.ЭлектронноеПисьмоВходящее";
	МетаданныеДокумента = Метаданные.Документы.ЭлектронноеПисьмоВходящее;
	
	Взаимодействия.ЗаполнитьВзаимодействияОснованияУПодчиненныхПисем(Параметры, ПолноеИмяДокумента, МетаданныеДокумента);
	
КонецПроцедуры

#КонецОбласти

#КонецОбласти

#КонецЕсли



