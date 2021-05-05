--Creación de base de datos--
create database ShopMarket
Go

use shopMarket
Go

--Creación de tablas--
create table Categorias
(
CodCategoria_C int identity(1,1),
Descripcion_C varchar(50) not null,
Estado_C bit not null,
constraint PK_Categorias primary key (CodCategoria_C)
)
Go
--

create table Productos
(
CodProd_P int identity(1,1),
CodCategoria_P int not null,
Descripcion_P varchar(50) not null,
Estado_P bit not null,
constraint PK_Productos primary key (CodProd_P),
constraint FK_Productos_Categorias foreign key (CodCategoria_P) references Categorias(CodCategoria_C)
)
Go
--
create table Proveedores
(
CodProveedor_Pr int identity(1,1),
RazonSocial_Pr varchar(50) not null,
Direccion_Pr varchar(50) not null,
Contacto_Pr varchar(50) not null,
Ciudad_Pr varchar(50) not null,
Pais_Pr varchar(50) not null,
CodPostal_Pr char(10) not null,
MetodoPago_Pr varchar(50) not null,
Telefono_Pr varchar(20) not null,
Estado_Pr bit not null,
constraint PK_Proveedores primary key (CodProveedor_Pr),
)
Go
--
create table ProductosxProveedores
(
CodProveedor_PXP int not null,
CodProducto_PXP int not null,
PrecioUnitario_PXP decimal(38,2) not null,
Stock_PXP int not null,
Estado_Pr bit not null,
constraint PK_ProductosxProveedores primary key (CodProveedor_PXP,CodProducto_PXP),
constraint FK_ProductosxProveedores_Productos foreign key(CodProducto_PXP) references Productos (CodProd_P),
constraint FK_ProductosxProveedores_Proveedores foreign key(CodProveedor_PXP) references Proveedores (CodProveedor_Pr)
)
Go
--
Create table Usuarios
(
Dni_U char(15) not null,
Email_U varchar(20) not null,
NombreUsuario_U varchar(20) not null,
ApellidoUsuario_U varchar(20) not null,
ContraseñaUsuario_U varchar(20) not null,
DireccionUsuario_U varchar(50) not null,
Sexo_U varchar(10) not null,
Estado_U bit not null,
constraint PK_Usuarios primary key (Dni_U)
)
Go
--
Create table Sucursales
(
IdSuc_S int identity(1,1),
Direccion_S varchar(50) not null,
CodPostal_S char(10) not null,
Nombre_S varchar(20) not null,
Estado_S bit not null,
constraint PK_Sucursales primary key (IdSuc_S)
)
Go
--
Create table Areas
(
NumArea_A int identity(1,1) not null,
Descripcion_A varchar(50) not null,
Estado_A bit not null,
constraint PK_Areas primary key (NumArea_A)
)
Go
--
create table Empleados
(
DniEmpleado_E char(15) not null,
IdSuc_E int not null,
NumArea_E int not null,
NombreEmpleado_E varchar(20) not null,
ApellidoEmpleado_E varchar(20) not null,
Direccion_E varchar(50) not null,
Estado_E bit not null,
constraint PK_Empleados primary key (DniEmpleado_E,IdSuc_E),
constraint FK_Empleados_Sucursales foreign key (IdSuc_E) references Sucursales (IdSuc_S),
constraint FK_Empleados_Areas foreign key (NumArea_E) references Areas (NumArea_A)
)
Go
--
create table Ventas
(
NumeroVenta_V int identity(1,1),
DniUsuario_V char(15) not null,
DniEmpleado_V char(15) not null,
IdSuc_V int not null,
Efectivo_V bit not null,
NumTarjeta_V char(16) null,
CodSeguridadTarjeta_V char(3) null,
MontoFinal decimal(38,2) null,
Fecha date not null,
constraint PK_Ventas primary key (NumeroVenta_V),
constraint FK_Ventas_Usuarios foreign key (DniUsuario_V) references Usuarios (Dni_U),
constraint FK_Ventas_Empleados foreign key (DniEmpleado_V,IdSuc_V) references Empleados (DniEmpleado_E,IdSuc_E)
)
Go
--
create table DetalleVentas
(
NumeroVenta_DV int not null,
NumOrden_DV int identity(1,1) not null,
CodProducto_DV int not null,
CodProveedor_DV int not null,
PrecioUnitario_DV decimal(38,2) not null,
Cantidad_DV int not null,
constraint PK_DetalleVentas primary key (NumeroVenta_DV,NumOrden_DV),
constraint FK_DetalleVentas_Ventas foreign key (NumeroVenta_DV) references Ventas(NumeroVenta_V),
constraint FK_DetalleVentas_ProductosxProveedores foreign key (CodProveedor_DV,CodProducto_DV) references ProductosxProveedores (CodProveedor_PXP,CodProducto_PXP)
)
Go

-- Creacion de procedimientos almacenados --
--- Productos 
create procedure SP_AgregarProducto
@CodCat int,
@Descripcion varchar(50)
as
declare @estado bit
select @estado = Estado_C from Categorias where CodCategoria_C=@CodCat
if(@estado=0)
begin
select 'No se puede ingresar la categoria ya que esta dada de baja ' as Mensaje
return
end
if exists (select * from Productos where Descripcion_P=@Descripcion) 
(Select 'Ya existe este producto' as Mensaje)
else
insert into Productos (Descripcion_P,CodCategoria_P,Estado_P)
values (@Descripcion,@CodCat,1)
go
---
create procedure SP_ModificarProducto
@CodCat int,
@Descripcion varchar(50),
@CodProd int
as
if exists (select * from Productos where Descripcion_P=@Descripcion)
(Select 'Ya existe la descripcion ingresada.' as Mensaje)
else
update Productos set Descripcion_P=@Descripcion,CodCategoria_P=@CodCat where CodProd_P=@CodProd
select 'Producto añadido con exito.' as Mensaje
Go
---
create procedure SP_EliminarProducto
@CodProd int
as 
update Productos set Estado_P=0 where CodProd_P=@CodProd
Select 'Borrado exitoso.' as Mensaje
Go
---
create procedure SP_BuscarNombreProducto
@Nombre varchar(50)
as
Select CodProd_P,Stock_PXP from Productos inner join ProductosxProveedores on Productos.CodProd_P=ProductosxProveedores.CodProducto_PXP where Descripcion_P like '%@Nombre%'
Go
---
create procedure SP_BuscarProductoCategoria
@CodCategoria int
as
select Descripcion_P,Stock_PXP,PrecioUnitario_PXP,CodProveedor_PXP,CodProd_P from Productos inner join ProductosxProveedores on Productos.CodProd_P=ProductosxProveedores.CodProducto_PXP
where CodCategoria_P=@CodCategoria
Go
---
create procedure SP_BuscarProducto
@CodProd int,
@CodProv int
as
select Descripcion_P,Stock_PXP from Productos inner join ProductosxProveedores on Productos.CodProd_P=ProductosxProveedores.CodProducto_PXP
where CodProducto_PXP=@CodProd and CodProveedor_PXP=@CodProv
Go
--- Proveedores
create procedure SP_AgregarProveedor
@Razon varchar(50),
@Direccion varchar(50),
@Contacto varchar(50),
@Ciudad varchar(50),
@Pais varchar(50),
@CodPostal char(10),
@Metodopago varchar(50),
@Telefono varchar(20)
as 
if exists (select * from Proveedores where RazonSocial_Pr=@Razon)
(Select 'Este proveedor ya está ingresado.' as Mensaje)
else
insert into Proveedores (RazonSocial_Pr,Direccion_Pr,Contacto_Pr,Ciudad_Pr,Pais_Pr,CodPostal_Pr,MetodoPago_Pr,Telefono_Pr, Estado_Pr)
values (@Razon,@Direccion,@Contacto,@Ciudad,@Pais,@CodPostal,@MetodoPago,@Telefono,1)
Go
---
create procedure SP_EliminarProveedor
@CodProv int
as
update Proveedores set Estado_Pr=0 where CodProveedor_Pr=@CodProv
Select 'Eliminado exitoso' as Mensaje
Go
---
create procedure SP_BuscarNombreProveedor
@Razon varchar(50)
as
Select CodProveedor_Pr,Direccion_Pr,Ciudad_Pr,Pais_Pr,MetodoPago_Pr from Proveedores where RazonSocial_Pr like '%@Razon%'
Go
---
create procedure SP_BuscarProveedor
@CodProv int
as
select RazonSocial_Pr,Direccion_Pr,Ciudad_Pr,Pais_Pr,Contacto_Pr,MetodoPago_Pr  from Proveedores where CodProveedor_Pr=@CodProv
Go
---
create procedure SP_ModificarProveedor
@Contacto varchar(50),
@Metodopago varchar(50),
@Telefono varchar(20),
@cod int
as 
update Proveedores set Contacto_Pr=@Contacto,MetodoPago_Pr=@MetodoPago,Telefono_Pr=@Telefono where CodProveedor_Pr=@cod
Go
--- ProductosxProveedor
create procedure SP_AgregarProdXProv
@CodProv int,
@CodProd int,
@PrecioUni decimal(38,2),
@Stock int
as
declare @estado bit
select @estado = Estado_P from Productos where CodProd_P=@CodProd
if(@estado=0)
begin
select 'No se puede ingresar el producto ya que esta dado de baja' as Mensaje
return
end
select @estado = Estado_Pr from Proveedores where CodProveedor_Pr=@CodProd
if(@estado=0)
begin
select 'No se puede ingresar el proveedor ya que esta dado de baja ' as Mensaje
return
end
insert into ProductosxProveedores(CodProducto_PXP,CodProveedor_PXP,Stock_PXP,PrecioUnitario_PXP,Estado_Pr)
values (@CodProd,@CodProv,@Stock,@PrecioUni,1)
Select 'Registro añadido con exito.' as Mensaje
Go
---
create procedure SP_EliminarProdxProv
@CodProv int,
@CodProd int
as
update ProductosxProveedores set Estado_Pr=0 where CodProducto_PXP=@CodProd and CodProveedor_PXP=@CodProv
select 'Eliminado exitoso.' as Mensaje
Go
---
create procedure SP_ModificarProdxProv
@CodProv int,
@CodProd int,
@stock int,
@precio decimal(38,2)
as
update ProductosxProveedores set Stock_PXP=@stock, PrecioUnitario_PXP=@precio where CodProducto_PXP=@CodProd and CodProveedor_PXP=@CodProv
select 'Modificacion exitosa.' as Mensaje
Go
--- Ventas y detalleVentas
create procedure SP_agregarVenta
@dniUsuario char(15),
@dniEmpleado char(15),
@efectivo bit,
@numTarjeta char(16)=null,
@codSeg char(3)=null
as
declare @idsuc int
select @idsuc=IdSuc_E from Empleados where DniEmpleado_E=@dniEmpleado
insert into Ventas (DniUsuario_V,DniEmpleado_V,Efectivo_V,NumTarjeta_V,CodSeguridadTarjeta_V,MontoFinal,Fecha,IdSuc_V)
values (@dniUsuario,@dniEmpleado,@efectivo,@numTarjeta,@codSeg,0,GETDATE(),@idsuc)
go
---
create procedure SP_agregarDetalleVenta
@numVenta int,
@codProducto int,
@codProveedor int,
@cant int
as

declare @precio decimal(38,2)
declare @stock int
declare @estado bit

select @stock = ProductosxProveedores.Stock_PXP from ProductosxProveedores where ProductosxProveedores.CodProducto_PXP = @codProducto and CodProveedor_PXP = @codProveedor
if (@stock=0)
begin
select 'No hay stock disponible.' as Mensaje
return
end
if(@stock < @cant and @cant > 0)
begin
print 'La cantidad ingresada no puede ser mayor al stock ('+cast(@stock as varchar)+') o menor a 0'
return
end
select @estado = Estado_Pr from ProductosxProveedores where ProductosxProveedores.CodProducto_PXP = @codProducto and CodProveedor_PXP = @codProveedor
if(@estado=0)
begin
select 'No se puede ingresar el producto ya que esta dado de baja ' as Mensaje
return
end
select @precio = ProductosxProveedores.PrecioUnitario_PXP from ProductosxProveedores where ProductosxProveedores.CodProducto_PXP = @codProducto and CodProveedor_PXP = @codProveedor
insert into DetalleVentas (NumeroVenta_DV,CodProducto_DV,CodProveedor_DV,PrecioUnitario_DV,Cantidad_DV)
values (@numVenta,@codProducto,@codProveedor,@precio,@cant)
go
---
create procedure SP_montoPorFecha
@fechaA date,
@fechaB date
as
select sum(MontoFinal) from Ventas where Fecha between @fechaA and @fechaB
go
---
create procedure SP_cantVendidaProducto
@codProd int,
@codProv int
as
declare @cantVendida int
select @cantVendida = sum(Cantidad_DV) from DetalleVentas where CodProducto_DV = @codProd and CodProveedor_DV = @codProv
print 'La cantidad vendida de este producto fue '+cast(@cantVendida as varchar)+'.'
go
--- Categorias, areas y empleados
create procedure SP_AgregarCategorias 
@Descripcion_C varchar(50) 
as  
if exists (select * from Categorias where Descripcion_C = @Descripcion_C )
 begin
 print 'La descripcion ya esta enlazada a una categoria.'
 return
 end 
 insert into Categorias (Descripcion_C,Estado_C)
 values (@Descripcion_C,1) 
 go
 ---
 create procedure SP_AgregarArea 
@Descripcion_A varchar(50)
as
if exists (select Areas.Descripcion_A from Areas where Descripcion_A = @Descripcion_A)
begin
print 'La descripcion ya esta enlazada a un Area'
return
end 
insert into Areas (Descripcion_A,Estado_A)
values (@Descripcion_A,1)
go
---
create procedure SP_AgregarEmpleados
@DniEmpleado_E char(15),
@IdSuc_E int,
@NumArea_E int,
@NombreEmpleado_E varchar(20),
@ApellidoEmpleado_E varchar(20),
@Direccion_E varchar(50)
as
if exists (select * from empleados where DniEmpleado_E = @DniEmpleado_E)
begin 
print 'Empleado ya existente'
return
end 
insert into Empleados (DniEmpleado_E,IdSuc_E,NumArea_E,NombreEmpleado_E,ApellidoEmpleado_E,Direccion_E,Estado_E)
values (@DniEmpleado_E,@IdSuc_E,@NumArea_E,@NombreEmpleado_E,@ApellidoEmpleado_E,@Direccion_E,1)
go 
---
create procedure SP_BajaLogicaAreas 
@NumArea_A int
as
update Areas set Estado_A = 0 where Areas.NumArea_A= @NumArea_A
select 'Eliminado exitoso.' as Mensaje
go
---
create procedure SP_BajaLogicaCategoria
@CodCategoria_C int 
as
update Categorias set Estado_C = 0 where Categorias.CodCategoria_C = @CodCategoria_C 
select 'Elimindo exitoso.' as Mensaje
go 
---
create procedure SP_BajaLogicaEmpleados 
@DniEmpleado_E char(15) 
as 
update Empleados set Estado_E = 0 where Empleados.DniEmpleado_E = @DniEmpleado_E 
select 'Eliminado exitoso.' as Mensaje
go 
---
create procedure SP_ModificarCategoria 
@cod int,
@Descripcion_C varchar(50)
as 
update Categorias set Descripcion_C = @Descripcion_C where Categorias.CodCategoria_C= @cod
select 'Modificacion exitosa.' as Mensaje
go
---
create procedure SP_ModificarArea 
@cod int, 
@Descripcion_A varchar(50)
as
update Areas set Descripcion_A = @Descripcion_A where Areas.NumArea_A = @cod 
select 'Modificacion exitosa.' as Mensaje
go 
---
create procedure SP_ModificarEmpleados 
@DniEmpleado_E char(15),
@NombreEmpleado_E varchar(20),
@ApellidoEmpleado_E varchar(20),
@Direccion_E varchar(50)
as 
update Empleados set NombreEmpleado_E = @NombreEmpleado_E , ApellidoEmpleado_E = @ApellidoEmpleado_E , Direccion_E = @Direccion_E where Empleados.DniEmpleado_E = @DniEmpleado_E
select 'Modificacion exitosa.' as Mensaje
go
--- Usuarios
create procedure SP_AgregarUsuario
@Dni varchar(15),
@Email varchar(20),
@Nombre varchar(20),
@Apellido varchar(20),
@contra varchar(20),
@Direccion varchar(50),
@sexo varchar(10)
as
if exists (select * from Usuarios where Dni_U=@Dni)
(Select 'Usuario ya ingresado.' as Mensaje)
else
insert into Usuarios (Dni_U,Email_U,NombreUsuario_U,ApellidoUsuario_U,ContraseñaUsuario_U,DireccionUsuario_U,Sexo_U,Estado_U)
values (@Dni,@Email,@Nombre,@Apellido,@contra,@Direccion,@sexo,1)
Go
---
create procedure SP_ModificarUsuario
@Dni varchar(15),
@Email varchar(20),
@contra varchar(20),
@Direccion varchar(50)
as
update Usuarios set Email_U=@Email,ContraseñaUsuario_U=@contra,DireccionUsuario_U=@Direccion where Dni_U=@Dni
select 'Usuario modificado con exito' as Mensaje
Go
---
create procedure SP_Eliminar
@Dni varchar(15)
as
update Usuarios set Estado_U=0 where Dni_U=@Dni
Go
-- Triggers --
use ShopMarket
Go
--- Trigger Monto final y resta de stock (Ventas)
create trigger VentasFinal
on DetalleVentas
after insert
as
begin
update Ventas set MontoFinal=MontoFinal+(select Cantidad_DV*PrecioUnitario_DV from inserted) where NumeroVenta_V=(select NumeroVenta_DV from inserted)
end
Go
---
create trigger BajasProdxProv
on productos
after update
as
begin
set nocount on;
if update(Estado_P)
begin
update ProductosxProveedores set Estado_Pr=0 where CodProducto_PXP=(select CodProd_P from inserted)
end
end
Go
---
create trigger StockVentas
on DetalleVentas
after insert
as
begin
update ProductosxProveedores set Stock_PXP=Stock_PXP-(select Cantidad_DV from inserted) where CodProducto_PXP=(select CodProducto_DV from inserted) and CodProveedor_PXP=(select CodProveedor_DV from inserted)
end
Go
--- Activar
create trigger SeguridadBorradoTablas
on database for DROP_TABLE,
ALTER_TABLE
as
begin
raiserror ('No esta permitido borrar o modificar tablas!' , 16, 1)
rollback transaction
end
Go
--- Activar
create trigger SeguridadBorradoVentas
on Ventas
after delete
as
begin
select 'No puedes borrar informacion de la tabla Ventas, ya que lo necesitaras a futuro!' as Mensaje
rollback 
end
Go
---
create trigger SeguridadBorradoDetalleVentas
on DetalleVentas
after delete
as
begin
select 'No puedes borrar informacion de la tabla Detalle de ventas, ya que lo necesitaras a futuro!' as Mensaje
rollback 
end
Go
---
create trigger BienvenidoUsuario
on Usuarios
after insert
as
begin
select 'Su usuario ha sido creado con exito, ¡Bienvenido a ShopMarket ' + (select NombreUsuario_U from inserted) + '!' as Mensaje
end
Go
---
create trigger CreacionFactura
on Ventas
after insert
as
begin
select 'Factura creada!' as Mensaje
end
Go
use ShopMarket
go
---
create trigger CreacionDetalleFactura
on DetalleVentas
after insert
as
begin
select 'Detalle de Factura creada!' as Mensaje
end
Go
---

--Consultas--
-- Productos y Proveedores
/*1)*/
Select Descripcion_P,Stock_PXP,RazonSocial_Pr from Productos 
inner join ProductosxProveedores on Productos.CodProd_P=ProductosxProveedores.CodProducto_PXP
inner join Proveedores on Proveedores.CodProveedor_Pr=ProductosxProveedores.CodProveedor_PXP
Go
/*2)*/
Select Pais_Pr as [Pais de origen],count(RazonSocial_Pr) as Proveedores from Proveedores
group by Pais_Pr
order by Pais_Pr asc
Go
/*3)*/
Select sum(Stock_PXP) as [Unidades en existencia] from ProductosxProveedores
where Estado_Pr=1
Go
/*4)*/
Select Stock_PXP as [Stock disponible], upper(Descripcion_P) as Producto from Productos 
inner join ProductosxProveedores on Productos.CodProd_P=ProductosxProveedores.CodProducto_PXP 
where Estado_P=1
Go
/*5)*/
Select CodProd_P,Descripcion_P as [Producto borrado] from Productos 
where Estado_P=0
Go
/*6)*/
Select CodProveedor_Pr,RazonSocial_Pr as [Proveedor borrado] from Proveedores 
where Estado_Pr=0
Go
/*7)*/
Select CodProd_P as Codigo,upper(Descripcion_P)as Producto from Productos 
where Descripcion_P like 'A%[^S]'
Go
/*8*/
select Descripcion_P,'Estado'= case
when Stock_PXP<100 then 'Poco stock disponible'
when Stock_PXP>100 then 'Suficiente stock disponible'
end
from Productos 
inner join ProductosxProveedores 
on Productos.CodProd_P=ProductosxProveedores.CodProducto_PXP
Go
/*9*/
select upper(RazonSocial_Pr) as Proveedores,'Condicion'= case
when Pais_Pr='Argentina' then 'Nacional'
when Pais_Pr!='Argentina' then 'Extranjera'
end
from Proveedores 
Go
-- Ventas y detalle ventas

/* DESPLEGAR CON VENTA NOMBRE Y APELLIDO DE CLIENTE*/

SELECT NumeroVenta_V,Dni_U,NombreUsuario_U,ApellidoUsuario_U,DniEmpleado_V,Efectivo_V,NumTarjeta_V,CodSeguridadTarjeta_V,MontoFinal,Fecha 
FROM Ventas INNER JOIN Usuarios 
ON Ventas.DniUsuario_V = Usuarios.Dni_U

/* DESPLEGAR CON DETALLE DE VENTA INFORMACION SOBRE EL PRODUCTO*/

SELECT NumeroVenta_DV, NumOrden_DV, CodProducto_PXP, CodProveedor_DV, Descripcion_P,PrecioUnitario_DV, Cantidad_DV, (Cantidad_DV * PrecioUnitario_DV) AS SubTotal FROM DetalleVentas 
INNER JOIN ProductosxProveedores 
ON DetalleVentas.CodProducto_DV = ProductosxProveedores.CodProducto_PXP AND DetalleVentas.CodProveedor_DV = DetalleVentas.CodProveedor_DV 
INNER JOIN Productos ON Productos.CodProd_P = ProductosxProveedores.CodProducto_PXP

/* PRODUCTO MAS VENDIDO */

SELECT TOP 1 CodProducto_DV,CodProveedor_DV,Descripcion_P,SUM(Cantidad_DV) AS Cantidad 
FROM DetalleVentas INNER JOIN Productos ON DetalleVentas.CodProducto_DV = Productos.CodProd_P 
GROUP BY CodProducto_DV, CodProveedor_DV,Descripcion_P
ORDER BY Cantidad DESC

/*Monto por fecha*/

select SUM(MontoFinal) as [Monto final] from Ventas WHERE Fecha between '01-01-1920' and '02-08-2030'
Go

/* MEJOR CLIENTE */

SELECT TOP 1 NombreUsuario_U, ApellidoUsuario_U,COUNT(DniUsuario_V) AS [Cantidad De Compras] FROM Ventas INNER JOIN Usuarios
ON Ventas.DniUsuario_V = Usuarios.Dni_U 
GROUP BY DniUsuario_V, NombreUsuario_U, ApellidoUsuario_U 
ORDER BY DniUsuario_V desc

/* CATEGORIA MAS VENDIDA */

SELECT TOP 1 Categorias.Descripcion_C AS [Categoria],SUM(Cantidad_DV) AS Cantidad 
FROM DetalleVentas INNER JOIN Productos ON DetalleVentas.CodProducto_DV = Productos.CodProd_P INNER JOIN 
Categorias ON Productos.CodCategoria_P = Categorias.CodCategoria_C
GROUP BY Descripcion_C
ORDER BY Cantidad desc

/* SUCURSAL CON MAS GANANCIA */

SELECT TOP 1 Sucursales.Nombre_S, SUM(MontoFinal) AS [Total Vendido]
FROM Ventas INNER JOIN Sucursales ON Ventas.IdSuc_V = Sucursales.IdSuc_S
GROUP BY Nombre_S
ORDER BY [Total Vendido] ASC

/* METODOS DE PAGO */

SELECT SUM(CASE WHEN Efectivo_V=1 THEN 1 ELSE 0 END) AS EFECTIVO, SUM(CASE WHEN Efectivo_V=0 THEN 1 ELSE 0 END) AS TARJETA FROM VENTAS

--Empleados
select NombreEmpleado_E,ApellidoEmpleado_E,DniEmpleado_E, NumArea_E from Empleados inner join Areas 
on 
NumArea_A = NumArea_E 
where Empleados.Estado_E = 1 
order by NumArea_A asc
---
select NombreEmpleado_E,ApellidoEmpleado_E,DniEmpleado_E, NumArea_E from Empleados inner join Sucursales
on 
IdSuc_S = IdSuc_E 
where Empleados.Estado_E = 1 
order by DniEmpleado_E desc 
---
select NombreEmpleado_E,ApellidoEmpleado_E,DniEmpleado_E,NumArea_E from empleados 
where Empleados.Estado_E = 1
order by ApellidoEmpleado_E asc
---
select NombreEmpleado_E,ApellidoEmpleado_E, sum(MontoFinal) as MayorVenta from empleados inner join ventas 
on 
DniEmpleado_E = DniEmpleado_V 
where Empleados.Estado_E = 1
group by NombreEmpleado_E,ApellidoEmpleado_E 
order by MayorVenta desc
--AREA
select NumArea_A, count(ApellidoEmpleado_E) as CantidadEmpleados from Areas inner join Empleados
on 
Areas.NumArea_A=Empleados.NumArea_E
where Areas.Estado_A = 1
group by NumArea_A 
--Categoria 
select Descripcion_C from categorias where Descripcion_C like '%[A-Z]%' and Estado_C=1
---
select CodCategoria_C, count(Productos.CodProd_P) as CantidadDeProductosDentroDeLaCategoria from Categorias inner join Productos
on 
CodCategoria_C = CodCategoria_P
where Estado_C = 1
group by CodCategoria_C 
--Usuarios
select NombreUsuario_U,ApellidoUsuario_U,Dni_U,Email_U,Sexo_U,DireccionUsuario_U from usuarios 
where Estado_U = 1
---
select NombreUsuario_U,ApellidoUsuario_U,Dni_U,Email_U,Sexo_U,DireccionUsuario_U from usuarios
where Estado_U = 1
order by Sexo_U desc 
---
select NombreUsuario_U,ApellidoUsuario_U,Dni_U,Email_U,Sexo_U,DireccionUsuario_U, sum(MontoFinal) as MayorComprador from usuarios
inner join Ventas 
on 
Dni_U = DniUsuario_V 
where Estado_U = 1
group by NombreUsuario_U,ApellidoUsuario_U, Dni_U,Email_U,Sexo_U,DireccionUsuario_U
order by  MayorComprador desc 
---
select NombreUsuario_U,ApellidoUsuario_U,Dni_U,Email_U,Sexo_U,DireccionUsuario_U from usuarios  
where Estado_U = 1
order by ApellidoUsuario_U 
---
select NombreUsuario_U,ApellidoUsuario_U,Dni_U,Email_U,Sexo_U,DireccionUsuario_U, count (Ventas.NumeroVenta_V)  as ContadorDeCompras from usuarios
inner join Ventas
on Dni_U = DniUsuario_V 
where Estado_U = 1
group by NombreUsuario_U,ApellidoUsuario_U, Dni_U,Email_U,Sexo_U,DireccionUsuario_U
order by ContadorDeCompras desc 
--Sucursales
select Direccion_S,CodPostal_S,Nombre_S, count (Empleados.DniEmpleado_E) as Trabajadores from Sucursales 
inner join Empleados 
on IdSuc_S = IdSuc_E
where Estado_S = 1
group by Direccion_S,CodPostal_S,Nombre_S
order by Trabajadores desc 
---
select Direccion_S,CodPostal_S,Nombre_S, IdSuc_S from Sucursales
where Estado_S = 1
order by IdSuc_S desc 
---
select Direccion_S,CodPostal_S,Nombre_S, IdSuc_S from Sucursales
where Estado_S = 1
order by Nombre_S desc 

---SUCURSALES
insert into Sucursales (Direccion_S,CodPostal_S,Nombre_S,Estado_S)
select 'Belgrano 433','1845B','ShopMarket Palermo',1 union
select 'Churich 1200','1745C','ShopMarket Escobar',1 union
select 'Lamberti 4099','1619','ShopMarket Garin',1 union
select 'Peron 245','5971','ShopMarket Barracas',1
Go
---USUARIOS
exec SP_AgregarUsuario '32891004','MarioP@gmail.com','Mario', 'Perez','123','Francia 247','Masculino'
exec SP_AgregarUsuario '47598632','claudio@gmail.com','Claudio', 'Gonzalez','123','Falco 670','Masculino'
exec SP_AgregarUsuario '49939878','tamara@gmail.com','Tamara', 'Lopez','123','Fournier 22','Femenino'
exec SP_AgregarUsuario '43889871','Ivan@gmail.com','Ivan', 'Jaurez','128','MItre 4555','Masculino'
exec SP_AgregarUsuario '35894122','Martata@gmail.com','Marta', 'Marciano','123','Lamberti 55','Femenino'
---CATEGORIAS
insert into Categorias (Descripcion_C,Estado_C)
select 'lacteos',1 union 
select 'congelados',1 union 
select 'bebidas',1 union  
select 'almacen',1 union   
select 'frutas y verduras',1 union   
select 'limpieza',1 union 
select 'electrodomesticos',1 union   
select 'perfumeria',1 union   
select 'quesos y fiambres',1
---PRODUCTOS
insert into Productos(CodCategoria_P,Descripcion_P,Estado_P)
select 9,'Otito Dulce de batata a la vainilla 500gr',1 union
select 9,'Esnaola Dulce de batata 500gr',1 union
select 9,'Dulcor Dulce de batata con chocolate 500gr',1 union
select 9,'Orieta Dulce de membrillo 500gr',1 union
select 9,'Excelencia Aceitunas deshuesadas 250gr',1 union
select 9,'Alfa Encurtido en vinagre 500gr',1 union
select 9,'Lorente Aceitunas sin hueso 2kg',1 union
select 9,'La coruña Pepinillos en conserva 250gr',1 union
select 9,'El friulano Salamin 1kg',1 union
select 9,'Bocatti Salame picado fino 350gr',1 union
select 9,'Bocatti Jamon cocido 100gr',1 union
select 9,'Ekono Jamon de cerdo 500gr',1 union
select 9,'Campo austral Jamon crudo 1kg',1 union
select 9,'Rica Mortadela 250gr',1 union
select 9,'Fontana Mortadela de pollo 300gr',1 union
select 9,'Éxito Mortadela seleccionada 250gr',1 union
select 9,'Blony Salchicha viena especial 150gr',1 union
select 9,'Big Dog Salchichas 417gr',1 union
select 9,'Kai Salchichas 450gr',1 union
select 9,'Zenú Salchichas tradicionales 225gr',1 union
select 9,'Castelar Queso azul (Horma entera) 2,5kg',1 union
select 9,'Emperador Queso azul 1/2kg',1 union
select 9,'Vacalin Muzzarella 500gr',1 union
select 9,'El fortín Queso muzzarella 1kg',1 union
select 9,'Clarita Queso cremoso 1kg',1 union
select 9,'Castelar Queso cremoso 1kg',1
---
insert into Productos(CodCategoria_P,Descripcion_P,Estado_P)
select 7,'Lavandina Querubin 2lt', 1 union
select 7, 'Jabon Liquido Ariel 3lt', 1 union
select 7, 'Desodorante ambiente Glade 420cc', 1 union
select 7, 'Papel higienico scott 4u',1 union
select 7, 'Papel higienico Higienol 4u',1 union
select 7, 'Lavandina en gel Vim 300ml', 1 union
select 7, 'Esponja lisa Virulana', 1 union
select 7, 'Rollitos Virulana 10u', 1 union
select 7, 'Escoba Perla 28cm', 1 union
select 7, 'Mopa Virulana Amarilla', 1 union
select 7, 'Pala p/ residuos La Perla', 1 union
select 7, 'Bolsas de residuos 50x70cm',1 union
select 7, 'Repasador tela guarda francesa', 1 union
select 7, 'Cesto vaiven cuadrado', 1 union
select 7, 'Escobilla de baño', 1 union
select 7, 'Guantes de cocina', 1 union
select 7, 'Canasta liquida Mr.Musculo', 1
---
insert into productos(CodCategoria_P,Descripcion_P,Estado_P)
select 4, 'Cafetera SMARTLIFE 1.5lt', 1 union
select 4, 'Horno electrico SMARTLIFE 40lts',1 union
select 4, 'Heladera Whirlpool 340lts',1 union
select 4, 'Impresora HP Laser Jet 107a', 1 union
select 4, 'Multiprocesadora Liliana 750w', 1 union
select 4, 'Netbook Lenovo corei5 259gb', 1 union
select 4, 'Aire acondicionado Alaska 3500w', 1 union
select 4, 'Lavarropas Drean Next 6kg', 1 union
select 4, 'Secarropas Columbia 5500 5.5kg', 1 union
select 4, 'Microondas BGH 28lts', 1 union
select 4, 'Freezer Sigma 350lts', 1 union
select 4, 'Exhibidora Vertical Bambi 370lt', 1 union
select 4, 'Heladera bajomesada Vondom 117lts',1 union
select 4, 'Termotanque a gas Rheem', 1 union 
select 4, 'Calefon Orbis 14lt', 1 union
select 4, 'Cocina Multigas Peabody', 1 union
select 4, 'Aspiradora ATMA con cable', 1 
---
insert into Productos (CodCategoria_P,Descripcion_P,Estado_P)
select 5,'pera',1 union
select 5,'manzana',1 union
select 5,'tomate',1 
---
insert into Productos (CodCategoria_P,Descripcion_P,Estado_P)
select 1,'galletitas formis',1 union
select 1,'dannete',1 union
select 1,'malvoro20',1 union
select 1,'chupetin',1 union
select 1,'encendedor',1 
---
insert into Productos (CodCategoria_P,Descripcion_P,Estado_P)
select 6,'Leche',1 union
select 6,'Manteca',1 union
select 6,'Helado',1 union
select 6,'Queso',1 union
select 6,'Yogurt',1 union
select 6,'Kefir',1 
 ---
insert into Productos (CodCategoria_P,Descripcion_P,Estado_P)
select 2,'Cerveza Brhama',1 union
select 2,'Cerveza Patagonia',1 union
select 2,'Vino Termidor',1 union
select 2,'Jaggermeiter',1 union
select 2,'Vodka Smirnoff',1 
 ---
insert into Productos (CodCategoria_P,Descripcion_P,Estado_P)
select 3,'McCain papas noisette',1 union
select 3,'McCain papas fritas',1 union
select 3,'Pizza congelada',1 union
select 3,'Langostinos Pelados Congelados',1 union
select 3,'Hamburguesa de soja',1 
---
insert into Productos (CodCategoria_P,Descripcion_P,Estado_P)
select 8,'Capilatis Shampoo linea proteccion 420ml',1 union
select 8,'Johnson´s Shampoo baby 200ml',1 
---AREAS
insert into Areas(Descripcion_A,Estado_A)
select 'Reposicion',1 union
select 'Administracion',1 union
select 'Electronica',1 union
select 'Caja',1 
---EMPLEADOS
insert into Empleados(DniEmpleado_E,IdSuc_E,NumArea_E,NombreEmpleado_E,ApellidoEmpleado_E,Direccion_E,Estado_E)
select '35456698',1,2,'Juana','Viale','Mitre 4555',1 union
select '29547130',2,3,'Martin','Rosas','Sulling 566',1 union
select '40258887',3,1,'Marta','Perez','Larroca 333',1 union
select '22148975',1,3,'Agustin','Romanow','Cabildo 555',1 union
select '42258997',1,2,'Luciana','Falco','Falco 569',1 
---PROVEEDORES
insert into Proveedores(RazonSocial_Pr,Direccion_Pr,Contacto_Pr,Ciudad_Pr,Pais_Pr,CodPostal_Pr,MetodoPago_Pr,Telefono_Pr,Estado_Pr)
select 'Dorado´s','Larroca 444','Dorado@gmail.com','Escobar','Argentina','5488','Efectivo','1115877842',1 union
select 'Lagos azules','Mitre 333','AzulesL@gmail.com','Palermo','Argentina','5620','Debito','111587436',1
select * from Productos
---PRODUCTOSXPROVEEDORES
insert into ProductosxProveedores(CodProveedor_PXP,CodProducto_PXP,PrecioUnitario_PXP,Stock_PXP,Estado_Pr)
select 1,25,150.5,541,1 union
select 2,30,200,544,1 union
select 2,80,500,41,1 union
select 1,86,360,44,1 union
select 1,55,250,87,1 union
select 1,20,58,58,1 union
select 2,32,1250,15,1 union
select 2,28,366,7,1 union
select 2,45,89,87,1 union
select 1,66,250.9,98,1 union
select 1,21,167,222,1 
---VENTAS
exec SP_agregarVenta '32891004','40258887',0,'2356894587415821','233'
exec SP_agregarVenta '47598632','22148975',1
exec SP_agregarVenta '35894122','42258997',1
exec SP_agregarVenta '49939878','40258887',1

---DETALLE DE VENTAS
exec SP_agregarDetalleVenta 1,45,2,20
exec SP_agregarDetalleVenta 2,66,1,12
exec SP_agregarDetalleVenta 3,21,1,15
exec SP_agregarDetalleVenta 4,55,1,30
