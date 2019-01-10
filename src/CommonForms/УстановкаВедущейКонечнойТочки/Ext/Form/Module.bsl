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

	СобытиеЖурналаРегистрацииУстановкаВедущейКонечнойТочки = ОбменСообщениямиВнутренний.СобытиеЖурналаРегистрацииУстановкаВедущейКонечнойТочки();
	
	КонечнаяТочка = Параметры.КонечнаяТочка;
	
	// Зачитываем значения настроек подключения.
	ЗаполнитьЗначенияСвойств(ЭтотОбъект, РегистрыСведений.НастройкиТранспортаОбменаСообщениями.НастройкиТранспортаWS(КонечнаяТочка));
	
	Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Установка ведущей конечной точки для ""%1""'"),
		ОбщегоНазначения.ЗначениеРеквизитаОбъекта(КонечнаяТочка, "Наименование"));
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	
	ТекстПредупреждения = НСтр("ru = 'Отменить выполнение операции?'");
	ОбщегоНазначенияКлиент.ПоказатьПодтверждениеЗакрытияПроизвольнойФормы(
		ЭтотОбъект, Отказ, ЗавершениеРаботы, ТекстПредупреждения, "ЗакрытьФормуБезусловно");
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Установить(Команда)
	
	Отказ = Ложь;
	ОшибкаЗаполнения = Ложь;
	
	УстановитьВедущуюКонечнуюТочкуНаСервере(Отказ, ОшибкаЗаполнения);
	
	Если ОшибкаЗаполнения Тогда
		Возврат;
	КонецЕсли;
	
	Если Отказ Тогда
		
		НСтрока = НСтр("ru = 'При установке ведущей конечной точки возникли ошибки.
		|Перейти в журнал регистрации?'");
		ОписаниеОповещения = Новый ОписаниеОповещения("ОткрытьЖурналРегистрации", ЭтотОбъект);
		ПоказатьВопрос(ОписаниеОповещения, НСтрока, РежимДиалогаВопрос.ДаНет, ,КодВозвратаДиалога.Нет);
		Возврат;
	КонецЕсли;
	
	Оповестить(ОбменСообщениямиКлиент.ИмяСобытияУстановленаВедущаяКонечнаяТочка());
	
	ПоказатьОповещениеПользователя(,, НСтр("ru = 'Установка ведущей конечной точки успешно завершена.'"));
	
	ЗакрытьФормуБезусловно = Истина;
	
	Закрыть();
	
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьЖурналРегистрации(Ответ, ДополнительныеПараметры) Экспорт
	
	Если Ответ = КодВозвратаДиалога.Да Тогда
		
		Отбор = Новый Структура;
		Отбор.Вставить("СобытиеЖурналаРегистрации", СобытиеЖурналаРегистрацииУстановкаВедущейКонечнойТочки);
		ОткрытьФорму("Обработка.ЖурналРегистрации.Форма", Отбор, ЭтотОбъект);
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура УстановитьВедущуюКонечнуюТочкуНаСервере(Отказ, ОшибкаЗаполнения)
	
	Если Не ПроверитьЗаполнение() Тогда
		ОшибкаЗаполнения = Истина;
		Возврат;
	КонецЕсли;
	
	НастройкиПодключенияWS = ОбменДаннымиСервер.СтруктураПараметровWS();
	
	ЗаполнитьЗначенияСвойств(НастройкиПодключенияWS, ЭтотОбъект);
	
	ОбменСообщениямиВнутренний.УстановитьВедущуюКонечнуюТочкуНаСторонеОтправителя(Отказ, НастройкиПодключенияWS, КонечнаяТочка);
	
КонецПроцедуры

#КонецОбласти
