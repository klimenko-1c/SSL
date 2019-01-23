﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныеПроцедурыИФункции

// Удаляет либо одну, либо все записи из регистра.
//
// Параметры:
//  Папка  - Справочник.ПапкиЭлектронныхПисем, Неопределено - папка, для которой удаляется запись.
//          Если указано значение Неопределено, то регистр будет очищен полностью.
//
Процедура УдалитьЗаписьИзРегистра(Папка = Неопределено) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	НаборЗаписей = СоздатьНаборЗаписей();
	Если Папка <> Неопределено Тогда
		НаборЗаписей.Отбор.Папка.Установить(Папка);
	КонецЕсли;
	
	НаборЗаписей.Записать();
	
КонецПроцедуры

// Выполняет запись в регистр сведений для указанной папки.
//
// Параметры:
//  Папка  - Справочник.ПапкиЭлектронныхПисем - папка, для которой выполняется запись.
//  Количество  - Число - количество не рассмотренных взаимодействий для этой папки.
//
Процедура ВыполнитьЗаписьВРегистр(Папка, Количество) Экспорт

	УстановитьПривилегированныйРежим(Истина);
	
	Запись = СоздатьМенеджерЗаписи();
	Запись.Папка = Папка;
	Запись.КоличествоНеРассмотрено = Количество;
	Запись.Записать(Истина);

КонецПроцедуры

#Область ОбработчикиОбновления

// Процедура обновления ИБ для версии БСП 2.2.
// Выполняет первоначальный расчет состояний папок взаимодействий.
//
Процедура РассчитатьСостоянияПапокЭлектронныхПисем_2_2_0_0(Параметры) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = "
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ПредметыПапкиВзаимодействий.ПапкаЭлектронногоПисьма КАК ПапкаЭлектронногоПисьма,
	|	СУММА(ВЫБОР
	|			КОГДА ПредметыПапкиВзаимодействий.Рассмотрено
	|				ТОГДА 0
	|			ИНАЧЕ 1
	|		КОНЕЦ) КАК КоличествоНеРассмотрено
	|ПОМЕСТИТЬ ИспользуемыеПапки
	|ИЗ
	|	РегистрСведений.ПредметыПапкиВзаимодействий КАК ПредметыПапкиВзаимодействий
	|ГДЕ
	|	ПредметыПапкиВзаимодействий.ПапкаЭлектронногоПисьма <> ЗНАЧЕНИЕ(Справочник.ПапкиЭлектронныхПисем.ПустаяСсылка)
	|
	|СГРУППИРОВАТЬ ПО
	|	ПредметыПапкиВзаимодействий.ПапкаЭлектронногоПисьма
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	ПапкаЭлектронногоПисьма
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ПапкиЭлектронныхПисем.Ссылка КАК ПапкаЭлектронногоПисьма,
	|	ЕСТЬNULL(ИспользуемыеПапки.КоличествоНеРассмотрено, 0) КАК КоличествоНеРассмотрено
	|ИЗ
	|	Справочник.ПапкиЭлектронныхПисем КАК ПапкиЭлектронныхПисем
	|		ЛЕВОЕ СОЕДИНЕНИЕ ИспользуемыеПапки КАК ИспользуемыеПапки
	|		ПО (ИспользуемыеПапки.ПапкаЭлектронногоПисьма = ПапкиЭлектронныхПисем.Ссылка)";
	
	Выборка = Запрос.Выполнить().Выбрать();

	Пока Выборка.Следующий() Цикл
		
		НаборЗаписей = СоздатьНаборЗаписей();
		НаборЗаписей.Отбор.Папка.Установить(Выборка.ПапкаЭлектронногоПисьма);
		Запись = НаборЗаписей.Добавить();
		Запись.Папка = Выборка.ПапкаЭлектронногоПисьма;
		Запись.КоличествоНеРассмотрено = Выборка.КоличествоНеРассмотрено;
		ОбновлениеИнформационнойБазы.ЗаписатьДанные(НаборЗаписей);
	
	КонецЦикла;
	
	Параметры.ОбработкаЗавершена = Истина;
	
КонецПроцедуры

#КонецОбласти

#КонецОбласти

#КонецЕсли