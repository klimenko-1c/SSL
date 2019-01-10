﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2018, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы
//

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АвтоТест") Тогда // Возврат при получении формы для анализа.
		Возврат;
	КонецЕсли;
	
	ЗакрыватьПриЗакрытииВладельца = Истина;
	
	Заголовок = Параметры.Заголовок;
	
	АдресКомпоновщикаНастроек = Параметры.АдресКомпоновщикаНастроек;
	Если ЗначениеЗаполнено(АдресКомпоновщикаНастроек) Тогда
		// Хранилище приоритетнее
		Данные = ПолучитьИзВременногоХранилища(АдресКомпоновщикаНастроек);
 		АдресСхемыКомпоновки = ПоместитьВоВременноеХранилище(Данные.СхемаКомпоновки, УникальныйИдентификатор);;
		КомпоновщикНастроек = Новый КомпоновщикНастроекКомпоновкиДанных;
		КомпоновщикНастроек.Инициализировать(Новый ИсточникДоступныхНастроекКомпоновкиДанных(АдресСхемыКомпоновки));
		КомпоновщикНастроек.ЗагрузитьНастройки(Данные.Настройки);
	Иначе
		АдресСхемыКомпоновки = "";
		КомпоновщикНастроек = Параметры.КомпоновщикНастроек;
	КонецЕсли;
	
	Параметры.Свойство("ПериодДанных", ПериодДанных);
	
	Если Параметры.ВыборПериода Тогда
		ВыгружатьЗаПериод = Истина;
	Иначе
		ВыгружатьЗаПериод = Ложь;
		// Отключаем выбор периода совсем.
		Элементы.ПериодДанных.Видимость = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	УстановитьДоступностьПериодаОтбора();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы
//

&НаКлиенте
Процедура ПериодДанныхОчистка(Элемент, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы
//

&НаКлиенте
Процедура КомандаОК(Команда)
	ОповеститьОВыборе(РезультатВыбора());
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции
//

&НаКлиенте
Процедура УстановитьДоступностьПериодаОтбора()
	Элементы.ПериодДанных.Доступность = ВыгружатьЗаПериод;
КонецПроцедуры

&НаСервере
Функция РезультатВыбора()
	Результат = Новый Структура;
	Результат.Вставить("ДействиеВыбора",      Параметры.ДействиеВыбора);
	Результат.Вставить("КомпоновщикНастроек", КомпоновщикНастроек);
	Результат.Вставить("ПериодДанных",        ?(ВыгружатьЗаПериод, ПериодДанных, Новый СтандартныйПериод));
	
	Результат.Вставить("АдресКомпоновщикаНастроек");
	Если Не ПустаяСтрока(АдресКомпоновщикаНастроек) Тогда
		Данные = Новый Структура;
		Данные.Вставить("Настройки", КомпоновщикНастроек.Настройки);
		
		СхемаКомпоновки = ?(ПустаяСтрока(АдресСхемыКомпоновки), Неопределено, ПолучитьИзВременногоХранилища(АдресСхемыКомпоновки));
		Данные.Вставить("СхемаКомпоновки", СхемаКомпоновки);
		
		Результат.АдресКомпоновщикаНастроек = ПоместитьВоВременноеХранилище(Данные, Параметры.АдресХранилищаФормы);
	КонецЕсли;
		
	Возврат Результат;
КонецФункции

#КонецОбласти
