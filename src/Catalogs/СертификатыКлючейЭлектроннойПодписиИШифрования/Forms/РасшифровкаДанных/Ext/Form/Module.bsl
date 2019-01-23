﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОписаниеПеременных

&НаКлиенте
Перем ВнутренниеДанные, СвойстваПароля, ОписаниеДанных, ФормаОбъекта, ОбработкаПослеПредупреждения, ТекущийСписокПредставлений;

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АвтоТест") Тогда // Возврат при получении формы для анализа.
		Возврат;
	КонецЕсли;
	
	ЭлектроннаяПодписьСлужебный.НастроитьПояснениеВводаПароля(ЭтотОбъект, ,
		Элементы.ПояснениеУсиленногоПароля.Имя);
	
	ЭлектроннаяПодписьСлужебный.НастроитьФормуПодписанияШифрованияРасшифровки(ЭтотОбъект, , Истина);
	
	РазрешитьЗапоминатьПароль = Параметры.РазрешитьЗапоминатьПароль;
	ЭтоАутентификация = Параметры.ЭтоАутентификация;
	
	Если ЭтоАутентификация Тогда
		Элементы.ФормаРасшифровать.Заголовок = НСтр("ru = 'ОК'");
		Элементы.ПояснениеУсиленногоПароля.Заголовок = НСтр("ru = 'Нажмите ОК, чтобы перейти к вводу пароля.'");
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если ВнутренниеДанные = Неопределено Тогда
		Отказ = Истина;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ИмяПоляАктивизироватьПоУмолчанию) Тогда
		ТекущийЭлемент = Элементы[ИмяПоляАктивизироватьПоУмолчанию];
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии(ЗавершениеРаботы)
	
	ОчиститьПеременныеФормы();
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ВРег(ИмяСобытия) = ВРег("Запись_СертификатыКлючейЭлектроннойПодписиИШифрования") Тогда
		ПодключитьОбработчикОжидания("ПриИзмененииСпискаСертификатов", 0.1, Истина);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ПредставлениеДанныхНажатие(Элемент, СтандартнаяОбработка)
	
	ЭлектроннаяПодписьСлужебныйКлиент.ПредставлениеДанныхНажатие(ЭтотОбъект,
		Элемент, СтандартнаяОбработка, ТекущийСписокПредставлений);
	
КонецПроцедуры

&НаКлиенте
Процедура СертификатПриИзменении(Элемент)
	
	ЭлектроннаяПодписьСлужебныйКлиент.ПолучитьОтпечаткиСертификатовНаКлиенте(
		Новый ОписаниеОповещения("СертификатПриИзмененииЗавершение", ЭтотОбъект));
	
КонецПроцедуры

// Продолжение процедуры СертификатПриИзменении.
&НаКлиенте
Процедура СертификатПриИзмененииЗавершение(ОтпечаткиСертификатовНаКлиенте, Контекст) Экспорт
	
	СертификатПриИзмененииНаСервере(ОтпечаткиСертификатовНаКлиенте);
	
	ЭлектроннаяПодписьСлужебныйКлиент.ОбработатьПарольВФорме(ЭтотОбъект, ВнутренниеДанные, СвойстваПароля);
	
КонецПроцедуры

&НаКлиенте
Процедура СертификатНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	Если ОтборСертификатов.Количество() > 0 Тогда
		ЭлектроннаяПодписьСлужебныйКлиент.НачалоВыбораСертификатаПриУстановленномОтборе(ЭтотОбъект);
		Возврат;
	КонецЕсли;
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("ВыбранныйСертификат", Сертификат);
	ПараметрыФормы.Вставить("ДляШифрованияИРасшифровки", Истина);
	ПараметрыФормы.Вставить("ВернутьПароль", Истина);
	
	ЭлектроннаяПодписьСлужебныйКлиент.ВыборСертификатаДляПодписанияИлиРасшифровки(ПараметрыФормы, Элемент);
	
КонецПроцедуры

&НаКлиенте
Процедура СертификатОткрытие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	Если ЗначениеЗаполнено(Сертификат) Тогда
		ЭлектроннаяПодписьКлиент.ОткрытьСертификат(Сертификат);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СертификатОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	Если ВыбранноеЗначение = Истина Тогда
		Сертификат = ВнутренниеДанные["ВыбранныйСертификат"];
		ВнутренниеДанные.Удалить("ВыбранныйСертификат");
		
	ИначеЕсли ВыбранноеЗначение = Ложь Тогда
		Сертификат = Неопределено;
		
	ИначеЕсли ТипЗнч(ВыбранноеЗначение) = Тип("Строка") Тогда
		ПараметрыФормы = Новый Структура;
		ПараметрыФормы.Вставить("ОтпечатокВыбранногоСертификата", ВыбранноеЗначение);
		ПараметрыФормы.Вставить("ДляШифрованияИРасшифровки", Истина);
		ПараметрыФормы.Вставить("ВернутьПароль", Истина);
		
		ЭлектроннаяПодписьСлужебныйКлиент.ВыборСертификатаДляПодписанияИлиРасшифровки(ПараметрыФормы, Элемент);
		Возврат;
	Иначе
		Сертификат = ВыбранноеЗначение;
	КонецЕсли;
	
	ЭлектроннаяПодписьСлужебныйКлиент.ПолучитьОтпечаткиСертификатовНаКлиенте(
		Новый ОписаниеОповещения("СертификатОбработкаВыбораЗавершение", ЭтотОбъект, ВыбранноеЗначение));
	
КонецПроцедуры

// Продолжение процедуры СертификатОбработкаВыбора.
&НаКлиенте
Процедура СертификатОбработкаВыбораЗавершение(ОтпечаткиСертификатовНаКлиенте, ВыбранноеЗначение) Экспорт
	
	СертификатПриИзмененииНаСервере(ОтпечаткиСертификатовНаКлиенте);
	
	Если ВыбранноеЗначение = Истина
	   И ВнутренниеДанные["ВыбранныйСертификатПароль"] <> Неопределено Тогда
		
		ЭлектроннаяПодписьСлужебныйКлиент.ОбработатьПарольВФорме(ЭтотОбъект,
			ВнутренниеДанные, СвойстваПароля,, ВнутренниеДанные["ВыбранныйСертификатПароль"]);
		ВнутренниеДанные.Удалить("ВыбранныйСертификатПароль");
		Элементы.ЗапомнитьПароль.ТолькоПросмотр = Ложь;
	Иначе
		ЭлектроннаяПодписьСлужебныйКлиент.ОбработатьПарольВФорме(ЭтотОбъект, ВнутренниеДанные, СвойстваПароля);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СертификатАвтоПодбор(Элемент, Текст, ДанныеВыбора, Параметры, Ожидание, СтандартнаяОбработка)
	
	ЭлектроннаяПодписьСлужебныйКлиент.СертификатПодборИзСпискаВыбора(ЭтотОбъект, Текст, ДанныеВыбора, СтандартнаяОбработка);
	
КонецПроцедуры

&НаКлиенте
Процедура СертификатОкончаниеВводаТекста(Элемент, Текст, ДанныеВыбора, Параметры, СтандартнаяОбработка)
	
	ЭлектроннаяПодписьСлужебныйКлиент.СертификатПодборИзСпискаВыбора(ЭтотОбъект, Текст, ДанныеВыбора, СтандартнаяОбработка);
	
КонецПроцедуры

&НаКлиенте
Процедура ПарольПриИзменении(Элемент)
	
	ЭлектроннаяПодписьСлужебныйКлиент.ОбработатьПарольВФорме(ЭтотОбъект,
		ВнутренниеДанные, СвойстваПароля, Новый Структура("ПриИзмененииРеквизитаПароль", Истина));
	
	Если Не РазрешитьЗапоминатьПароль
	   И Не ЗапомнитьПароль
	   И Не СвойстваПароля.ПарольПроверен Тогда
		
		Элементы.ЗапомнитьПароль.ТолькоПросмотр = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗапомнитьПарольПриИзменении(Элемент)
	
	ЭлектроннаяПодписьСлужебныйКлиент.ОбработатьПарольВФорме(ЭтотОбъект,
		ВнутренниеДанные, СвойстваПароля, Новый Структура("ПриИзмененииРеквизитаЗапомнитьПароль", Истина));
	
	Если Не РазрешитьЗапоминатьПароль
	   И Не ЗапомнитьПароль
	   И Не СвойстваПароля.ПарольПроверен Тогда
		
		Элементы.ЗапомнитьПароль.ТолькоПросмотр = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПояснениеУстановленногоПароляНажатие(Элемент)
	
	ЭлектроннаяПодписьСлужебныйКлиент.ПояснениеУстановленногоПароляНажатие(ЭтотОбъект, Элемент, СвойстваПароля);
	
КонецПроцедуры

&НаКлиенте
Процедура ПояснениеУстановленногоПароляРасширеннаяПодсказкаОбработкаНавигационнойСсылки(Элемент, НавигационнаяСсылка, СтандартнаяОбработка)
	
	ЭлектроннаяПодписьСлужебныйКлиент.ПояснениеУстановленногоПароляОбработкаНавигационнойСсылки(
		ЭтотОбъект, Элемент, НавигационнаяСсылка, СтандартнаяОбработка, СвойстваПароля);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Расшифровать(Команда)
	
	Если Не Элементы.ФормаРасшифровать.Доступность Тогда
		Возврат;
	КонецЕсли;
	
	Если Не ПроверитьЗаполнение() Тогда
		Возврат;
	КонецЕсли;
	
	Элементы.ФормаРасшифровать.Доступность = Ложь;
	
	РасшифроватьДанные(Новый ОписаниеОповещения("РасшифроватьЗавершение", ЭтотОбъект));
	
КонецПроцедуры

// Продолжение процедуры Расшифровать.
&НаКлиенте
Процедура РасшифроватьЗавершение(Результат, Контекст) Экспорт
	
	Элементы.ФормаРасшифровать.Доступность = Истина;
	
	Если Результат = Истина Тогда
		Закрыть(Истина);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ПродолжитьОткрытие(Оповещение, ОбщиеВнутренниеДанные, КлиентскиеПараметры) Экспорт
	
	Если КлиентскиеПараметры = ВнутренниеДанные Тогда
		КлиентскиеПараметры = Новый Структура("Сертификат, СвойстваПароля", Сертификат, СвойстваПароля);
		Возврат;
	КонецЕсли;
	
	Если КлиентскиеПараметры.Свойство("УказанКонтекстДругойОперации") Тогда
		СвойстваСертификата = ОбщиеВнутренниеДанные;
		КлиентскиеПараметры.ОписаниеДанных.КонтекстОперации.ПродолжитьОткрытие(Неопределено, Неопределено, СвойстваСертификата);
		Если СвойстваСертификата.Сертификат = Сертификат Тогда
			СвойстваПароля = СвойстваСертификата.СвойстваПароля;
		КонецЕсли;
	КонецЕсли;
	
	ОписаниеДанных             = КлиентскиеПараметры.ОписаниеДанных;
	ФормаОбъекта               = КлиентскиеПараметры.Форма;
	ТекущийСписокПредставлений = КлиентскиеПараметры.ТекущийСписокПредставлений;
	
	ВнутренниеДанные = ОбщиеВнутренниеДанные;
	Контекст = Новый Структура("Оповещение", Оповещение);
	Оповещение = Новый ОписаниеОповещения("ПродолжитьОткрытие", ЭтотОбъект);
	
	ЭлектроннаяПодписьСлужебныйКлиент.ПродолжитьОткрытиеНачало(Новый ОписаниеОповещения(
		"ПродолжитьОткрытиеПослеНачала", ЭтотОбъект, Контекст), ЭтотОбъект, КлиентскиеПараметры,, Истина);
	
КонецПроцедуры

// Продолжение процедуры ПродолжитьОткрытие.
&НаКлиенте
Процедура ПродолжитьОткрытиеПослеНачала(Результат, Контекст) Экспорт
	
	Если Результат <> Истина Тогда
		ПродолжитьОткрытиеЗавершение(Контекст);
		Возврат;
	КонецЕсли;
	
	ДополнительныеПараметры = Новый Структура;
	Если СвойстваПароля <> Неопределено Тогда
		ДополнительныеПараметры.Вставить("ПриУстановкеПароляИзДругойОперации", Истина);
	КонецЕсли;
	ЭлектроннаяПодписьСлужебныйКлиент.ОбработатьПарольВФорме(ЭтотОбъект,
		ВнутренниеДанные, СвойстваПароля, ДополнительныеПараметры);
	
	Если Не РазрешитьЗапоминатьПароль
	   И Не ЗапомнитьПароль
	   И Не СвойстваПароля.ПарольПроверен Тогда
		
		Элементы.ЗапомнитьПароль.ТолькоПросмотр = Истина;
	КонецЕсли;
	
	Если БезПодтверждения
	   И (    ДополнительныеПараметры.ПарольУказан
	      Или ДополнительныеПараметры.УсиленнаяЗащитаЗакрытогоКлюча) Тогда
	
		ОбработкаПослеПредупреждения = Неопределено;
		РасшифроватьДанные(Новый ОписаниеОповещения("ПродолжитьОткрытиеПослеРасшифровкиДанных", ЭтотОбъект, Контекст));
		Возврат;
	КонецЕсли;
	
	Открыть();
	
	ПродолжитьОткрытиеЗавершение(Контекст);
	
КонецПроцедуры

// Продолжение процедуры ПродолжитьОткрытие.
&НаКлиенте
Процедура ПродолжитьОткрытиеПослеРасшифровкиДанных(Результат, Контекст) Экспорт
	
	ПродолжитьОткрытиеЗавершение(Контекст, Результат = Истина);
	
КонецПроцедуры

// Продолжение процедуры ПродолжитьОткрытие.
&НаКлиенте
Процедура ПродолжитьОткрытиеЗавершение(Контекст, Результат = Неопределено)
	
	Если Не Открыта() Тогда
		ОчиститьПеременныеФормы();
	КонецЕсли;
	
	ВыполнитьОбработкуОповещения(Контекст.Оповещение, Результат);
	
КонецПроцедуры

&НаКлиенте
Процедура ОчиститьПеременныеФормы()
	
	ОписаниеДанных             = Неопределено;
	ФормаОбъекта               = Неопределено;
	ТекущийСписокПредставлений = Неопределено;
	
КонецПроцедуры

// АПК:78-выкл: для безопасной передачи данных на клиенте между формами, не отправляя их на сервер.
&НаКлиенте
Процедура ВыполнитьРасшифровку(КлиентскиеПараметры, ОбработкаЗавершения) Экспорт
// АПК:78-вкл: для безопасной передачи данных на клиенте между формами, не отправляя их на сервер.
	
	ЭлектроннаяПодписьСлужебныйКлиент.ОбновитьФормуПередПовторнымИспользованием(ЭтотОбъект, КлиентскиеПараметры);
	
	ОписаниеДанных             = КлиентскиеПараметры.ОписаниеДанных;
	ФормаОбъекта               = КлиентскиеПараметры.Форма;
	ТекущийСписокПредставлений = КлиентскиеПараметры.ТекущийСписокПредставлений;
	
	ОбработкаПослеПредупреждения = ОбработкаЗавершения;
	
	Контекст = Новый Структура("ОбработкаЗавершения", ОбработкаЗавершения);
	РасшифроватьДанные(Новый ОписаниеОповещения("ВыполнитьРасшифровкуЗавершение", ЭтотОбъект, Контекст));
	
КонецПроцедуры

// Продолжение процедуры ВыполнитьРасшифровку.
&НаКлиенте
Процедура ВыполнитьРасшифровкуЗавершение(Результат, Контекст) Экспорт
	
	Если Результат = Истина Тогда
		ВыполнитьОбработкуОповещения(Контекст.ОбработкаЗавершения, Истина);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриИзмененииСпискаСертификатов()
	
	ЭлектроннаяПодписьСлужебныйКлиент.ПолучитьОтпечаткиСертификатовНаКлиенте(
		Новый ОписаниеОповещения("ПриИзмененииСпискаСертификатовЗавершение", ЭтотОбъект));
	
КонецПроцедуры

// Продолжение процедуры ПриИзмененииСпискаСертификатов.
&НаКлиенте
Процедура ПриИзмененииСпискаСертификатовЗавершение(ОтпечаткиСертификатовНаКлиенте, Контекст) Экспорт
	
	СертификатПриИзмененииНаСервере(ОтпечаткиСертификатовНаКлиенте, Истина);
	
	ЭлектроннаяПодписьСлужебныйКлиент.ОбработатьПарольВФорме(ЭтотОбъект,
		ВнутренниеДанные, СвойстваПароля, Новый Структура("ПриИзмененииСвойствСертификата", Истина));
	
КонецПроцедуры

&НаСервере
Процедура СертификатПриИзмененииНаСервере(ОтпечаткиСертификатовНаКлиенте, ПроверитьСсылку = Ложь)
	
	Если ПроверитьСсылку
	   И ЗначениеЗаполнено(Сертификат)
	   И ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Сертификат, "Ссылка") <> Сертификат Тогда
		
		Сертификат = Неопределено;
	КонецЕсли;
	
	ЭлектроннаяПодписьСлужебный.СертификатПриИзмененииНаСервере(ЭтотОбъект, ОтпечаткиСертификатовНаКлиенте,, Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура РасшифроватьДанные(Оповещение)
	
	Контекст = Новый Структура;
	Контекст.Вставить("Оповещение", Оповещение);
	Контекст.Вставить("ОшибкаНаКлиенте", Новый Структура);
	Контекст.Вставить("ОшибкаНаСервере", Новый Структура);
	
	Если Не ЗначениеЗаполнено(СертификатПрограмма) Тогда
		Контекст.ОшибкаНаКлиенте.Вставить("ОписаниеОшибки",
			НСтр("ru = 'У выбранного сертификата не указана программа для закрытого ключа.
			           |Выберите сертификат повторно из полного списка или
			           |откройте сертификат и укажите программу вручную.'"));
		ПоказатьОшибку(Контекст.ОшибкаНаКлиенте, Контекст.ОшибкаНаСервере);
		ВыполнитьОбработкуОповещения(Контекст.Оповещение, Ложь);
		Возврат;
	КонецЕсли;
	
	ВыбранныйСертификат = Новый Структура;
	ВыбранныйСертификат.Вставить("Ссылка",    Сертификат);
	ВыбранныйСертификат.Вставить("Отпечаток", СертификатОтпечаток);
	ВыбранныйСертификат.Вставить("Данные",    СертификатАдрес);
	ОписаниеДанных.Вставить("ВыбранныйСертификат", ВыбранныйСертификат);
	
	Если ОписаниеДанных.Свойство("ПередВыполнением")
	   И ТипЗнч(ОписаниеДанных.ПередВыполнением) = Тип("ОписаниеОповещения") Тогда
		
		ПараметрыВыполнения = Новый Структура;
		ПараметрыВыполнения.Вставить("ОписаниеДанных", ОписаниеДанных);
		ПараметрыВыполнения.Вставить("Оповещение", Новый ОписаниеОповещения(
			"РасшифроватьДанныеПослеОбработкиПередВыполнением", ЭтотОбъект, Контекст));
		
		ВыполнитьОбработкуОповещения(ОписаниеДанных.ПередВыполнением, ПараметрыВыполнения);
	Иначе
		РасшифроватьДанныеПослеОбработкиПередВыполнением(Новый Структура, Контекст);
	КонецЕсли;
	
КонецПроцедуры

// Продолжение процедуры РасшифроватьДанные.
&НаКлиенте
Процедура РасшифроватьДанныеПослеОбработкиПередВыполнением(Результат, Контекст) Экспорт
	
	Если Результат.Свойство("ОписаниеОшибки") Тогда
		ПоказатьОшибку(Новый Структура("ОписаниеОшибки", Результат.ОписаниеОшибки), Новый Структура);
		Возврат;
	КонецЕсли;
	
	Контекст.Вставить("ИдентификаторФормы", УникальныйИдентификатор);
	Если ТипЗнч(ФормаОбъекта) = Тип("УправляемаяФорма") Тогда
		Контекст.ИдентификаторФормы = ФормаОбъекта.УникальныйИдентификатор;
	ИначеЕсли ТипЗнч(ФормаОбъекта) = Тип("УникальныйИдентификатор") Тогда
		Контекст.ИдентификаторФормы = ФормаОбъекта;
	КонецЕсли;
	
	ПараметрыВыполнения = Новый Структура;
	ПараметрыВыполнения.Вставить("ОписаниеДанных",     ОписаниеДанных);
	ПараметрыВыполнения.Вставить("Форма",              ЭтотОбъект);
	ПараметрыВыполнения.Вставить("ИдентификаторФормы", Контекст.ИдентификаторФормы);
	ПараметрыВыполнения.Вставить("ЗначениеПароля",     СвойстваПароля.Значение);
	Контекст.Вставить("ПараметрыВыполнения", ПараметрыВыполнения);
	
	Если ЭлектроннаяПодписьКлиент.СоздаватьЭлектронныеПодписиНаСервере() Тогда
		Если ЗначениеЗаполнено(СертификатНаСервереОписаниеОшибки) Тогда
			Результат = Новый Структура("Ошибка", СертификатНаСервереОписаниеОшибки);
			СертификатНаСервереОписаниеОшибки = Новый Структура;
			РасшифроватьДанныеПослеВыполненияНаСторонеСервера(Результат, Контекст);
		Иначе
			// Попытка шифрования на сервере.
			ЭлектроннаяПодписьСлужебныйКлиент.ВыполнитьНаСтороне(Новый ОписаниеОповещения(
					"РасшифроватьДанныеПослеВыполненияНаСторонеСервера", ЭтотОбъект, Контекст),
				"Расшифровка", "НаСторонеСервера", Контекст.ПараметрыВыполнения);
		КонецЕсли;
	Иначе
		РасшифроватьДанныеПослеВыполненияНаСторонеСервера(Неопределено, Контекст);
	КонецЕсли;
	
	
КонецПроцедуры

// Продолжение процедуры РасшифроватьДанные.
&НаКлиенте
Процедура РасшифроватьДанныеПослеВыполненияНаСторонеСервера(Результат, Контекст) Экспорт
	
	Если Результат <> Неопределено Тогда
		РасшифроватьДанныеПослеВыполнения(Результат);
	КонецЕсли;
	
	Если Результат <> Неопределено И Не Результат.Свойство("Ошибка") Тогда
		РасшифроватьДанныеПослеВыполненияНаСторонеКлиента(Новый Структура, Контекст);
	Иначе
		Если Результат <> Неопределено Тогда
			Контекст.ОшибкаНаСервере = Результат.Ошибка;
		КонецЕсли;
		
		// Попытка подписания на клиенте.
		ЭлектроннаяПодписьСлужебныйКлиент.ВыполнитьНаСтороне(Новый ОписаниеОповещения(
				"РасшифроватьДанныеПослеВыполненияНаСторонеКлиента", ЭтотОбъект, Контекст),
			"Расшифровка", "НаСторонеКлиента", Контекст.ПараметрыВыполнения);
	КонецЕсли;
	
КонецПроцедуры

// Продолжение процедуры РасшифроватьДанные.
&НаКлиенте
Процедура РасшифроватьДанныеПослеВыполненияНаСторонеКлиента(Результат, Контекст) Экспорт
	
	РасшифроватьДанныеПослеВыполнения(Результат);
	
	Если Результат.Свойство("Ошибка") Тогда
		Контекст.ОшибкаНаКлиенте = Результат.Ошибка;
		ПоказатьОшибку(Контекст.ОшибкаНаКлиенте, Контекст.ОшибкаНаСервере);
		ВыполнитьОбработкуОповещения(Контекст.Оповещение, Ложь);
		Возврат;
	КонецЕсли;
	
	Если Не ЗаписатьСертификатыШифрования(Контекст.ИдентификаторФормы, Контекст.ОшибкаНаКлиенте) Тогда
		ПоказатьОшибку(Контекст.ОшибкаНаКлиенте, Контекст.ОшибкаНаСервере);
		ВыполнитьОбработкуОповещения(Контекст.Оповещение, Ложь);
		Возврат;
	КонецЕсли;
	
	Если Не ЭтоАутентификация
	   И ЗначениеЗаполнено(ПредставлениеДанных)
	   И (Не ОписаниеДанных.Свойство("СообщитьОЗавершении")
	      Или ОписаниеДанных.СообщитьОЗавершении <> Ложь) Тогда
		
		ЭлектроннаяПодписьКлиент.ИнформироватьОРасшифровкеОбъекта(
			ЭлектроннаяПодписьСлужебныйКлиент.ПолноеПредставлениеДанных(ЭтотОбъект),
			ТекущийСписокПредставлений.Количество() > 1);
	КонецЕсли;
	
	Если ОписаниеДанных.Свойство("КонтекстОперации") Тогда
		ОписаниеДанных.КонтекстОперации = ЭтотОбъект;
	КонецЕсли;
	
	ВыполнитьОбработкуОповещения(Контекст.Оповещение, Истина);
	
КонецПроцедуры

// Продолжение процедуры РасшифроватьДанные.
&НаКлиенте
Процедура РасшифроватьДанныеПослеВыполнения(Результат)
	
	Если Результат.Свойство("ОперацияНачалась") Тогда
		ЭлектроннаяПодписьСлужебныйКлиент.ОбработатьПарольВФорме(ЭтотОбъект, ВнутренниеДанные,
			СвойстваПароля, Новый Структура("ПриУспешномВыполненииОперации", Истина));
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Функция ЗаписатьСертификатыШифрования(ИдентификаторФормы, Ошибка)
	
	ОписаниеОбъектов = Новый Массив;
	Если ОписаниеДанных.Свойство("Данные") Тогда
		ДобавитьОписаниеОбъекта(ОписаниеОбъектов, ОписаниеДанных);
	Иначе
		Для Каждого ЭлементДанных Из ОписаниеДанных.НаборДанных Цикл
			ДобавитьОписаниеОбъекта(ОписаниеОбъектов, ЭлементДанных);
		КонецЦикла;
	КонецЕсли;
	
	Ошибка = Новый Структура;
	ЗаписатьСертификатыШифрованияНаСервере(ОписаниеОбъектов, ИдентификаторФормы, Ошибка);
	
	Возврат Не ЗначениеЗаполнено(Ошибка);
	
КонецФункции

&НаКлиенте
Процедура ДобавитьОписаниеОбъекта(ОписаниеОбъектов, ЭлементДанных)
	
	Если Не ЭлементДанных.Свойство("Объект") Тогда
		Возврат;
	КонецЕсли;
	
	ВерсияОбъекта = Неопределено;
	ЭлементДанных.Свойство("ВерсияОбъекта", ВерсияОбъекта);
	
	ОписаниеОбъекта = Новый Структура;
	ОписаниеОбъекта.Вставить("Ссылка", ЭлементДанных.Объект);
	ОписаниеОбъекта.Вставить("Версия", ВерсияОбъекта);
	
	ОписаниеОбъектов.Добавить(ОписаниеОбъекта);
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ЗаписатьСертификатыШифрованияНаСервере(ОписаниеОбъектов, ИдентификаторФормы, Ошибка)
	
	СертификатыШифрования = Новый Массив;
	
	НачатьТранзакцию();
	Попытка
		Для каждого ОписаниеОбъекта Из ОписаниеОбъектов Цикл
			ЭлектроннаяПодпись.ЗаписатьСертификатыШифрования(ОписаниеОбъекта.Ссылка,
				СертификатыШифрования, ИдентификаторФормы, ОписаниеОбъекта.Версия);
		КонецЦикла;
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		Ошибка.Вставить("ОписаниеОшибки", НСтр("ru = 'При очистке сертификатов шифрования возникла ошибка:'")
			+ Символы.ПС + КраткоеПредставлениеОшибки(ИнформацияОбОшибке));
	КонецПопытки;
	
КонецПроцедуры


&НаКлиенте
Процедура ПоказатьОшибку(ОшибкаНаКлиенте, ОшибкаНаСервере)
	
	Если Не Открыта() И ОбработкаПослеПредупреждения = Неопределено Тогда
		Открыть();
	КонецЕсли;
	
	ЭлектроннаяПодписьСлужебныйКлиент.ПоказатьОшибкуОбращенияКПрограмме(
		НСтр("ru = 'Не удалось расшифровать данные'"), "",
		ОшибкаНаКлиенте, ОшибкаНаСервере, , ОбработкаПослеПредупреждения);
	
КонецПроцедуры

#КонецОбласти
