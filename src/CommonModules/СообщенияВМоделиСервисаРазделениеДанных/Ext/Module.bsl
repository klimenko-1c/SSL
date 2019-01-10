﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2018, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

// Вызывается при заполнении массива справочников, которые могут использоваться для
// хранения сообщений.
//
// Параметры:
//  МассивСправочник - Массив - в этот параметр в данном методе должны быть добавлены
//    менеджеры справочников, которые могут использоваться для хранения заданий очереди.
//
Процедура ПриЗаполненииСправочниковСообщений(МассивСправочников) Экспорт
	
	МассивСправочников.Добавить(Справочники.СообщенияОбластейДанных);
	
КонецПроцедуры

// Выбирает справочник для сообщения.
//
// Параметры:
// ТелоСообщения - Произвольный - тело сообщения.
//
Функция ПриВыбореСправочникаДляСообщения(Знач ТелоСообщения) Экспорт
	
	Сообщение = Неопределено;
	Если СообщенияВМоделиСервиса.ТелоСодержитТипизированноеСообщение(ТелоСообщения, Сообщение) Тогда
		
		Если СообщенияВМоделиСервисаПовтИсп.ТипТелоОбласти().ЭтоПотомок(Сообщение.Body.Тип()) Тогда
			
			Возврат Справочники.СообщенияОбластейДанных;
			
		КонецЕсли;
		
	Иначе
		
		Если РаботаВМоделиСервиса.ИспользованиеРазделителяСеанса() Тогда
			Возврат Справочники.СообщенияОбластейДанных;
		КонецЕсли;
		
	КонецЕсли;
	
КонецФункции

// Вызывается перед записью элемента справочника сообщений.
//
// Параметры:
//  ОбъектСообщения - СправочникОбъект.СообщенияСистемы, СправочникОбъект.СообщенияОбластейДанных,
//  СтандартнаяОбработка - Булево.
//
Процедура ПередЗаписьюСообщения(ОбъектСообщения, СтандартнаяОбработка) Экспорт
	
	Сообщение = Неопределено;
	Если СообщенияВМоделиСервиса.ТелоСодержитТипизированноеСообщение(ОбъектСообщения.ТелоСообщения.Получить(), Сообщение) Тогда
		
		Если СообщенияВМоделиСервисаПовтИсп.ТипТелоОбласти().ЭтоПотомок(Сообщение.Body.Тип()) Тогда
			
			ОбъектСообщения.ОбластьДанныхВспомогательныеДанные = Сообщение.Body.Zone;
			
		КонецЕсли;
		
	КонецЕсли;
	
	СтандартнаяОбработка = Ложь;
	РаботаВМоделиСервиса.ЗаписатьВспомогательныеДанные(ОбъектСообщения);
	
КонецПроцедуры

// Обработчик события при отправке сообщения.
// Обработчик данного события вызывается перед помещением сообщения в XML-поток.
// Обработчик вызывается для каждого отправляемого сообщения.
//
// Параметры:
//  КаналСообщений - Строка - идентификатор канала сообщений, в который отправляется сообщение.
//  ТелоСообщения - Произвольный - Тело отправляемого сообщения. В обработчике события тело сообщения
//    может быть изменено, например, дополнено информацией.
//
Процедура ПриОтправкеСообщения(КаналСообщений, ТелоСообщения, ОбъектСообщения) Экспорт
	
	Сообщение = Неопределено;
	Если СообщенияВМоделиСервиса.ТелоСодержитТипизированноеСообщение(ТелоСообщения, Сообщение) Тогда
		
		Если РаботаВМоделиСервиса.ДоступноИспользованиеРазделенныхДанных()
			И СообщенияВМоделиСервисаПовтИсп.ТипТелоОбласти().ЭтоПотомок(Сообщение.Body.Тип()) Тогда
			
			Если РаботаВМоделиСервиса.ЗначениеРазделителяСеанса() <> Сообщение.Body.Zone Тогда
				ШаблонСообщения = НСтр("ru = 'Попытка отправить сообщение от имени области %1 из области %2'");
				ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонСообщения, Сообщение.Body.Zone,
					РаботаВМоделиСервиса.ЗначениеРазделителяСеанса());
				ВызватьИсключение(ТекстСообщения);
			КонецЕсли;
		КонецЕсли;
		
		Если СообщенияВМоделиСервисаПовтИсп.ТипАутентифицированноеТелоОбласти().ЭтоПотомок(Сообщение.Body.Тип()) Тогда
			
			Если РаботаВМоделиСервиса.ДоступноИспользованиеРазделенныхДанных() Тогда
				Сообщение.Body.ZoneKey = Константы.КлючОбластиДанных.Получить();
			Иначе
				УстановитьПривилегированныйРежим(Истина);
				РаботаВМоделиСервиса.УстановитьРазделениеСеанса(Истина, Сообщение.Body.Zone);
				Сообщение.Body.ZoneKey = Константы.КлючОбластиДанных.Получить();
				РаботаВМоделиСервиса.УстановитьРазделениеСеанса(Ложь);
			КонецЕсли;
			
		КонецЕсли;
		
		ТелоСообщения = СообщенияВМоделиСервиса.ЗаписатьСообщениеВНетипизированноеТело(Сообщение);
		
	КонецЕсли;
	
	Если ТипЗнч(ОбъектСообщения) <> Тип("СправочникОбъект.СообщенияСистемы") Тогда
		
		ПодменаОбъектаСообщения = Справочники.СообщенияСистемы.СоздатьЭлемент();
		
		ЗаполнитьЗначенияСвойств(ПодменаОбъектаСообщения, ОбъектСообщения, , "Родитель,Владелец");
		
		ПодменаОбъектаСообщения.УстановитьСсылкуНового(Справочники.СообщенияСистемы.ПолучитьСсылку(
			ОбъектСообщения.Ссылка.УникальныйИдентификатор()));
		
		ОбъектСообщения = ПодменаОбъектаСообщения;
		
	КонецЕсли;
	
КонецПроцедуры

// Обработчик события при получении сообщения.
// Обработчик данного события вызывается при получении сообщения из XML-потока.
// Обработчик вызывается для каждого получаемого сообщения.
//
// Параметры:
//  КаналСообщений - Строка - идентификатор канала сообщений, из которого получено сообщение.
//  ТелоСообщения - Произвольный - Тело полученного сообщения. В обработчике события тело
//    сообщения может быть изменено, например, дополнено информацией.
//
Процедура ПриПолученииСообщения(КаналСообщений, ТелоСообщения, ОбъектСообщения) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	Сообщение = Неопределено;
	Если СообщенияВМоделиСервиса.ТелоСодержитТипизированноеСообщение(ТелоСообщения, Сообщение) Тогда
		
		Если РаботаВМоделиСервисаПовтИсп.ЭтоРазделеннаяКонфигурация() Тогда
			
			ПереопределенныйСправочник = ПриВыбореСправочникаДляСообщения(ТелоСообщения);
			
			Если ПереопределенныйСправочник <> Неопределено Тогда
				
				Если ТипЗнч(ПереопределенныйСправочник.ПустаяСсылка()) <> ТипЗнч(ОбъектСообщения.Ссылка) Тогда
					
					ПодменаОбъектаСообщенияСсылка = ПереопределенныйСправочник.ПолучитьСсылку(
						ОбъектСообщения.ПолучитьСсылкуНового().УникальныйИдентификатор());
					
					Если ОбщегоНазначения.СсылкаСуществует(ПодменаОбъектаСообщенияСсылка) Тогда
						
						ПодменаОбъектаСообщения = ПодменаОбъектаСообщенияСсылка.ПолучитьОбъект();
						
					Иначе
						
						ПодменаОбъектаСообщения = ПереопределенныйСправочник.СоздатьЭлемент();
						ПодменаОбъектаСообщения.УстановитьСсылкуНового(ПодменаОбъектаСообщенияСсылка);
						
					КонецЕсли;
					
					ЗаполнитьЗначенияСвойств(ПодменаОбъектаСообщения, ОбъектСообщения, , "Родитель,Владелец");
					ПодменаОбъектаСообщения.ОбластьДанныхВспомогательныеДанные = Сообщение.Body.Zone;
					
					ОбъектСообщения = ПодменаОбъектаСообщения;
					
				КонецЕсли;
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

// Процедура вызывается при начале обработки входящего сообщения.
//
// Параметры:
//  Сообщение - ОбъектXDTO - входящее сообщение,
//  Отправитель - ПланОбменаСсылка.ОбменСообщениями - узел плана обмена, соответствующей
//    информационной базе, отправившей сообщение.
//
Процедура ПриНачалеОбработкиСообщения(Знач Сообщение, Знач Отправитель) Экспорт
	
	Если СообщенияВМоделиСервисаПовтИсп.ТипТелоОбласти().ЭтоПотомок(Сообщение.Body.Тип()) Тогда
		
		РаботаВМоделиСервиса.УстановитьРазделениеСеанса(Истина, Сообщение.Body.Zone);
		ОбработатьКлючОбластиВСообщении(Сообщение);
		
	КонецЕсли;
	
КонецПроцедуры

// Процедура вызывается после обработки входящего сообщения.
//
// Параметры:
//  Сообщение - ОбъектXDTO - входящее сообщение,
//  Отправитель - ПланОбменаСсылка.ОбменСообщениями - узел плана обмена, соответствующей
//    информационной базе, отправившей сообщение,
//  СообщениеОбработано - булево, флаг того, что сообщение было успешно обработано. Если значение
//    установлено равным Ложь - после выполнения этой процедуры будет вызвано исключение. В данной
//    процедуре значение данного параметра может быть изменено.
//
Процедура ПослеОбработкиСообщения(Знач Сообщение, Знач Отправитель, СообщениеОбработано) Экспорт
	
	Если СообщенияВМоделиСервисаПовтИсп.ТипТелоОбласти().ЭтоПотомок(Сообщение.Body.Тип()) Тогда
		
		РаботаВМоделиСервиса.УстановитьРазделениеСеанса(Ложь);
		
	КонецЕсли;
	
КонецПроцедуры

// Процедура вызывается при возникновении ошибки обработки сообщения.
//
// Параметры:
//  Сообщение - ОбъектXDTO - входящее сообщение,
//  Отправитель - ПланОбменаСсылка.ОбменСообщениями - узел плана обмена, соответствующей
//    информационной базе, отправившей сообщение.
//
Процедура ПриОшибкеОбработкиСообщения(Знач Сообщение, Знач Отправитель) Экспорт
	
	Если СообщенияВМоделиСервисаПовтИсп.ТипТелоОбласти().ЭтоПотомок(Сообщение.Body.Тип()) Тогда
		
		РаботаВМоделиСервиса.УстановитьРазделениеСеанса(Ложь);
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ОбработатьКлючОбластиВСообщении(Сообщение)
	
	СообщениеСодержитКлючОбласти = Ложь;
	
	Если СообщенияВМоделиСервисаПовтИсп.ТипАутентифицированноеТелоОбласти().ЭтоПотомок(Сообщение.Body.Тип()) Тогда
		СообщениеСодержитКлючОбласти = Истина;
	КонецЕсли;
	
	Если Не СообщениеСодержитКлючОбласти Тогда
		
		МассивОбработчиков = Новый Массив();
		ВызываемыйМодуль = ОбщегоНазначения.ОбщийМодуль("СообщенияУдаленногоАдминистрированияИнтерфейс");
		ВызываемыйМодуль.ОбработчикиКаналовСообщений(МассивОбработчиков);
		Для Каждого Обработчик Из МассивОбработчиков Цикл
			
			ТипСообщенияОбработчика = ВызываемыйМодуль.СообщениеУстановитьПараметрыОбластиДанных(
				Обработчик.Пакет());
			
			Если Сообщение.Body.Тип() = ТипСообщенияОбработчика Тогда
				СообщениеСодержитКлючОбласти = Истина;
				Прервать;
			КонецЕсли;
			
		КонецЦикла;
		
	КонецЕсли;
	
	Если СообщениеСодержитКлючОбласти Тогда
		
		ТекущийКлючОбласти = Константы.КлючОбластиДанных.Получить();
		
		Если Не ЗначениеЗаполнено(ТекущийКлючОбласти) Тогда
			
			Константы.КлючОбластиДанных.Установить(Сообщение.Body.ZoneKey);
			
		Иначе
			
			Если ПроверкаКлючаОбластиВСообщенияхВозможна() Тогда
				
				Если ТекущийКлючОбласти <> Сообщение.Body.ZoneKey Тогда
					
					ВызватьИсключение НСтр("ru = 'Неверный ключ области данных в сообщении'");
					
				КонецЕсли;
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

Функция ПроверкаКлючаОбластиВСообщенияхВозможна()
	
	СтруктураНастроек = РегистрыСведений.НастройкиТранспортаОбменаСообщениями.НастройкиТранспортаWS(
		РаботаВМоделиСервиса.КонечнаяТочкаМенеджераСервиса());
	ПараметрыПодключенияКМС = Новый Структура;
	ПараметрыПодключенияКМС.Вставить("URL",      СтруктураНастроек.WSURLВебСервиса);
	ПараметрыПодключенияКМС.Вставить("UserName", СтруктураНастроек.WSИмяПользователя);
	ПараметрыПодключенияКМС.Вставить("Password", СтруктураНастроек.WSПароль);
	
	МаксимальнаяВерсия = Неопределено;
	ВерсииМС = ОбщегоНазначения.ПолучитьВерсииИнтерфейса(ПараметрыПодключенияКМС, "СообщенияВМоделиСервиса");
	Если ВерсииМС = Неопределено Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Для Каждого ВерсияМС Из ВерсииМС Цикл
		
		Если МаксимальнаяВерсия = Неопределено Тогда
			МаксимальнаяВерсия = ВерсияМС;
		Иначе
			МаксимальнаяВерсия = ?(ОбщегоНазначенияКлиентСервер.СравнитьВерсии(
				ВерсияМС, МаксимальнаяВерсия) > 0, ВерсияМС,
				МаксимальнаяВерсия);
		КонецЕсли;
		
	КонецЦикла;
	
	Если ВерсияМС = Неопределено Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Возврат (ОбщегоНазначенияКлиентСервер.СравнитьВерсии(МаксимальнаяВерсия, "1.0.4.1") >= 0);
	
КонецФункции

#КонецОбласти
