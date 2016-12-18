//
//  ViewController.swift
//  HiddenPokemonSearcher
//

import UIKit
import MapKit
import CoreLocation

class MainViewController: UIViewController, MKMapViewDelegate {

    // MARK: - Internal
    // contents
    @IBOutlet weak var mainContentsView: UIView!
    @IBOutlet weak var mainContentsBottomLayoutConstraint: NSLayoutConstraint!

    // map area
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var currentPlaceButton: UIButton!
    
    // guide area
    @IBOutlet weak var guideMessageLabel: PaddingLabel!
    
    // button area
    @IBOutlet weak var searchStartButton: UIButton!
    @IBOutlet weak var disappearFirstTimeButton: UIButton!
    @IBOutlet weak var disappearSecondTimeButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var pokegoAppbutton: UIButton!
    
    // Navi bar area
    @IBOutlet weak var settingBarButton: UIBarButtonItem!
    
    // MARK: - Private
    private var adMgr = AdModMgr()
    private var lcMgr = LocationMgr()
    
    private enum PROC_STATE {
        case WAIT_START
        case WAIT_DISAPPEAR_FIRST
        case WAIT_DISAPPEAR_SECOND
        case FINISH
    }
    private var procState: PROC_STATE = PROC_STATE.WAIT_START
    
    private enum PROC_EVENT {
        case TAP_CURRENT_LOCATION
        case TAP_SEARCH_START
        case TAP_DISAPPEAR_FIRST
        case TAP_DISAPPEAR_SECOND
        case TAP_RESET
    }
    
    private var targetCircle = MKCircle()
    private var firstSearchLine = MKPolyline()
    private var secondSearchLine = MKPolyline()
    private var firstToSecondLine = MKPolyline()
    private var targetSearchLine = MKPolyline()
    private var hiddenLine = MKPolyline()
    private var annotationStart = MKPointAnnotation()
    private var annotationFirst = MKPointAnnotation()
    private var annotationSecond = MKPointAnnotation()
    
    // MARK: - Debug Parameter
#if DEBUG
    private let debug_FirstPin_latitude: CLLocationDegrees = -0.001  // 緯度
    private let debug_FirstPin_longitude: CLLocationDegrees = -0.001 // 経度
#else
    private let debug_FirstPin_latitude: CLLocationDegrees = 0.0  // 緯度
    private let debug_FirstPin_longitude: CLLocationDegrees = 0.0 // 経度
#endif
    private var debug_p2r_slope: Double = 0.0
    private var debug_f_mp = MKMapPoint()
    
    // MARK: - ViewController Override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // *** Each initialization process ***
        
        // Application procedures
        initProc()
        
        // AdMod manager
        adMgr.initManager(pvc:self, cv:mainContentsView, lc: mainContentsBottomLayoutConstraint)
        
        // Location manager
        lcMgr.initMgr(pvc:self)
        lcMgr.StartLocationSearch()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        adMgr.dispAdView(pos: AdModMgr.DISP_POSITION.BOTTOM)
        initEachViewItem()
        procStateMgr(PROC_EVENT.TAP_RESET)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - ViewController Action
    /**
     [Action]SearchStartButton Event:TouchDown
     */
    @IBAction func SearchStartButton_TouchDown(_ sender: Any) {
        procStateMgr(PROC_EVENT.TAP_SEARCH_START)
    }
    
    /**
     [Action]Disappear1stButton Event:TouchDown
     */
    @IBAction func Disappear1stButton_TouchDown(_ sender: Any) {
        procStateMgr(PROC_EVENT.TAP_DISAPPEAR_FIRST)
    }
    
    /**
     [Action]Disappear2ndButton Event:TouchDown
     */
    @IBAction func Disappear2ndButton_TouchDown(_ sender: Any) {
        procStateMgr(PROC_EVENT.TAP_DISAPPEAR_SECOND)
    }
    
    /**
     [Action]ResetButton Event:TouchDown
     */
    @IBAction func ResetButton_TouchDown(_ sender: Any) {
        procStateMgr(PROC_EVENT.TAP_RESET)
    }

    
    /**
     [Action]CurrentPositionButton Event:TouchDown
     */
    @IBAction func CurrentPositionButton_TouchDown(_ sender: Any) {
        procStateMgr(PROC_EVENT.TAP_CURRENT_LOCATION)
    }

    /**
     [Action]PokeGoAppButton Event:TouchDown
     */
    @IBAction func PokeGoAppButton_TouchDown(_ sender: UIButton) {
        
        let url = NSURL(string: "com.googleusercontent.apps.848232511240-dmrj3gba506c9svge2p9gq35p1fg654p://")!
        if (UIApplication.shared.canOpenURL(url as URL)) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url as URL)
            }
        }
    }
    
    // MARK: - MKMapViewDelegate
    /**
     [Delegate]mapView -> MKOverlayRenderer
     */
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      
        if (overlay.isEqual(targetCircle)){
            let circleRenderer : MKCircleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.strokeColor = UIColor.green
            circleRenderer.fillColor = UIColor(red: 0.0, green: 0.7, blue: 0.0, alpha: 0.25)
            circleRenderer.lineWidth = 1.0
            return circleRenderer
        }
        else if (overlay.isEqual(firstSearchLine)) {
            
            let lineRender = MKPolylineRenderer(overlay: overlay)
            lineRender.lineWidth = 3
            lineRender.strokeColor = UIColor.yellow
            return lineRender
        }
        else if (overlay.isEqual(secondSearchLine)) {
            
            let lineRender = MKPolylineRenderer(overlay: overlay)
            lineRender.lineWidth = 30
            lineRender.alpha = 0.3
            lineRender.strokeColor = UIColor.blue
            
            return lineRender
        }
        else if (overlay.isEqual(firstToSecondLine)) {
            
            let lineRender = MKPolylineRenderer(overlay: overlay)
            lineRender.lineWidth = 3
            lineRender.strokeColor = UIColor.orange
            
            return lineRender
        }
        else if (overlay.isEqual(targetSearchLine)) {
            
            let lineRender = MKPolylineRenderer(overlay: overlay)
            lineRender.lineWidth = 6
            lineRender.strokeColor = UIColor.red
            return lineRender
        }
        
        return MKCircleRenderer(overlay: overlay)
    }
 
    /**
     [Delegate] mapView -> MKAnnotationView
     */
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
    
        if (annotation.isEqual(annotationStart)) {
            pinView = subMakeAnnotationView(annotation: annotation, id: "annotationCenter") as! MKPinAnnotationView
            pinView.pinTintColor = UIColor.blue
            pinView.canShowCallout = true
        }
        else if (annotation.isEqual(annotationFirst)) {
            pinView = subMakeAnnotationView(annotation: annotation, id: "annotationFirst") as! MKPinAnnotationView
            pinView.pinTintColor = UIColor.red
            pinView.canShowCallout = true
        }
        else if (annotation.isEqual(annotationSecond)) {
            pinView = subMakeAnnotationView(annotation: annotation, id: "annotationSecond") as! MKPinAnnotationView
            pinView.pinTintColor = UIColor.red
            pinView.canShowCallout = true
        }
        else {
            return nil
        }
        
        return pinView
    }
    
    /**
     [sub function] Make new AnnotationView if there is not it.
     */
    func subMakeAnnotationView(annotation: MKAnnotation, id: String) -> MKAnnotationView? {
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: id ) as? MKPinAnnotationView
        if (pinView != nil) {
            pinView!.annotation = annotation
            
        } else {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: id)
        }
        
        return pinView!
    }
    
    // MARK: - Private method
    /**
     Initialization procedures
     */
    private func initProc() {
        
        // coordinate information
        targetCircle = MKCircle()
        firstSearchLine = MKPolyline()
        secondSearchLine = MKPolyline()
        targetSearchLine = MKPolyline()
        hiddenLine = MKPolyline()
        annotationStart = MKPointAnnotation()
        annotationFirst = MKPointAnnotation()
        annotationSecond = MKPointAnnotation()
        
        // procedures state
        procState = PROC_STATE.WAIT_START
    }
    
    /**
     Initialize each view item.
     */
    private func initEachViewItem() {
        
        // mapview
        mapView.delegate = self
        
        // map area
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(MKUserTrackingMode.followWithHeading, animated: true)
        
        currentPlaceButton.layer.borderWidth = 0.5
        currentPlaceButton.layer.borderColor = UIColor.white.cgColor
        currentPlaceButton.layer.cornerRadius = 3.5
        currentPlaceButton.setTitle(NSLocalizedString("MSG_BUTTON_CURRENT_PLACE", comment: ""), for: .normal)
        
        // guide area
        guideMessageLabel.layer.borderWidth = 2.0
        guideMessageLabel.layer.borderColor = UIColor.white.cgColor
        guideMessageLabel.layer.cornerRadius = 5.0
        guideMessageLabel.text = ""
        guideMessageLabel.numberOfLines = 0
        guideMessageLabel.text = "123456789012345678901234567890123456789012345\n" +
                                    "123456789012345678901234567890123456789012345\n" +
                                    "123456789012345678901234567890123456789012345\n" +
                                    "123456789012345678901234567890123456789012345"

        guideMessageLabel.fontSizeToFit()
        guideMessageLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        guideMessageLabel.text = ""

        // button area
        searchStartButton.titleLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping
        searchStartButton.titleLabel!.numberOfLines = 2
        searchStartButton.setTitle(NSLocalizedString("MSG_BUTTON_SEARCH_START", comment: ""), for: .normal)
        searchStartButton.setTitleColor(UIColor.white, for: .normal)
        searchStartButton.setTitleColor(UIColor.lightGray, for: .disabled)
        searchStartButton.titleLabel!.textAlignment = NSTextAlignment.center
        
        disappearFirstTimeButton.titleLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping
        disappearFirstTimeButton.titleLabel!.numberOfLines = 2
        disappearFirstTimeButton.setTitle(NSLocalizedString("MSG_BUTTON_DISAPPEAR_1ST", comment: ""), for: .normal)
        disappearFirstTimeButton.setTitleColor(UIColor.white, for: .normal)
        disappearFirstTimeButton.setTitleColor(UIColor.lightGray, for: .disabled)
        disappearFirstTimeButton.titleLabel!.textAlignment = NSTextAlignment.center
        
        disappearSecondTimeButton.titleLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping
        disappearSecondTimeButton.titleLabel!.numberOfLines = 2
        disappearSecondTimeButton.setTitle(NSLocalizedString("MSG_BUTTON_DISAPPEAR_2ND", comment: ""), for: .normal)
        disappearSecondTimeButton.setTitleColor(UIColor.white, for: .normal)
        disappearSecondTimeButton.setTitleColor(UIColor.lightGray, for: .disabled)
        disappearSecondTimeButton.titleLabel!.textAlignment = NSTextAlignment.center
        
        resetButton.setTitle(NSLocalizedString("MSG_BUTTON_RESET", comment: ""), for: .normal)
        resetButton.titleLabel!.textAlignment = NSTextAlignment.center
        resetButton.backgroundColor = UIColor.hexStr(hexStr: "c0542d", alpha: 1)
        
        pokegoAppbutton.titleLabel?.numberOfLines = 2
        pokegoAppbutton.titleLabel!.textAlignment = NSTextAlignment.center
        pokegoAppbutton.setTitle("PoKe\nGo", for: .normal)
        
        // navi bar area
        self.navigationItem.title = NSLocalizedString("TITLE_MAIN", comment: "")
        settingBarButton.title = ""
        settingBarButton.width = 0
        let settingIcon = UIImage(named: "icon_setting")?.ResizeUIImage(width: 20, height: 20)
        settingBarButton.image = settingIcon
    }

    /**
     Disp current location
     */
    private func dispCurrentLocation() {
        
        if (lcMgr.latitude != nil && lcMgr.longitude != nil ) {
            
            let center = CLLocationCoordinate2DMake(lcMgr.latitude!, lcMgr.longitude!)
            let range = ((CLLocationDistance(AppPreference.GetHiddenRadius()) * 2.0)) + (CLLocationDistance(AppPreference.GetHiddenRadius()) / 4)
            let region = MKCoordinateRegionMakeWithDistance(center, range, range)
            mapView.setRegion(region, animated:true)
        }
    }
    
    // MARK: - State Procedure
    /**
     Initialization of processing
     - parameter state: procedure state
     - returns: nothing
     */
    private func procStateMgr( _ event: PROC_EVENT) {
        
        // The common event processing for all state.
        switch event {
        case PROC_EVENT.TAP_CURRENT_LOCATION:
            dispCurrentLocation()
        case PROC_EVENT.TAP_RESET:
            initProc()
            initEachViewItem()
            procState = PROC_STATE.WAIT_START
        default:
            // no action
            break;
        }
        
        // Event driven processing
        switch procState {
            
        case PROC_STATE.WAIT_START:
            proc_Evt_WaitStart(event)
        case PROC_STATE.WAIT_DISAPPEAR_FIRST:
            proc_Evt_DisappearFirst(event)
        case PROC_STATE.WAIT_DISAPPEAR_SECOND:
            proc_Evt_DisappearSecond(event)
        case PROC_STATE.FINISH:
            proc_Evt_Finish(event)
        }
        
        // State driven processing
        proc_St_SetGuide(procState)
        proc_St_SetViewItem(procState)
    }

    /**
     [Event Driven] State: WaitStart
     - parameter event: Events that occurred
     - returns: nothing
     */
    private func proc_Evt_WaitStart(_ event: PROC_EVENT) {
        
        switch event {
        case PROC_EVENT.TAP_SEARCH_START:
            
            if (lcMgr.available == true) {
                
                // *** 現在地を適切なスケールで表示 ***
                dispCurrentLocation()
                
                // *** 開始地点へピンを立てる ***
                annotationStart.coordinate = CLLocationCoordinate2DMake(lcMgr.latitude!, lcMgr.longitude!)
                annotationStart.title = NSLocalizedString("MSG_ANNOTATION_START", comment: "")
                self.mapView.addAnnotation(annotationStart)
                
                // *** ポケモンが隠れているエリアを半透明の円で塗りつぶす ***
                let coordinate = CLLocationCoordinate2DMake(lcMgr.latitude!, lcMgr.longitude!)
                targetCircle = MKCircle(center: coordinate, radius: Double(AppPreference.GetHiddenRadius()))
                mapView.add(targetCircle)
                
                // *** 状態遷移 ***
                procState = PROC_STATE.WAIT_DISAPPEAR_FIRST
            }
            else {
                // 位置情報が取得できない場合はエラーを表示して、現状態を維持する
                SimpleAlert.AlertMsg(pcv: self, msg: NSLocalizedString("MSG_LOCATION_ERROR", comment: ""))
            }

        default:
            break;
        }
        
    }
    
    /**
     [Event Driven] State: DisappearFirst
     - parameter event: Events that occurred
     - returns: nothing
     */
    private func proc_Evt_DisappearFirst(_ event: PROC_EVENT) {
        
        switch event {
        case PROC_EVENT.TAP_DISAPPEAR_FIRST:
            
            if (lcMgr.available == true) {
                
                // *** 消失(１回目)の位置へピンを立てる ****
                annotationFirst.coordinate = CLLocationCoordinate2DMake(
                    (lcMgr.latitude! + debug_FirstPin_latitude)
                    ,(lcMgr.longitude! + debug_FirstPin_longitude))
                annotationFirst.title = NSLocalizedString("MSG_ANNOTATION_FIRST", comment: "")
                self.mapView.addAnnotation(annotationFirst)
                
                // *** 開始位置から消失(１回目)までの線を描画し、その線分の垂直二等分線（消失２回目のガイドライン）を描画する ****
                let s_mp = MKMapPointForCoordinate(annotationStart.coordinate)
                let f_mp = MKMapPointForCoordinate(annotationFirst.coordinate)
                
                let s_loc = MKCoordinateForMapPoint(MKMapPoint(x: s_mp.x,y: s_mp.y))
                let f_loc = MKCoordinateForMapPoint(MKMapPoint(x: f_mp.x,y: f_mp.y))
                
                // 開始位置から消失(１回目)までの線を描画
                var s2f_loc:[CLLocationCoordinate2D] =
                    [CLLocationCoordinate2D(latitude: s_loc.latitude, longitude: s_loc.longitude),
                     CLLocationCoordinate2D(latitude: f_loc.latitude, longitude: f_loc.longitude)]
                firstSearchLine = MKPolyline(coordinates: &s2f_loc, count: 2)
                mapView.add(firstSearchLine)
                
                // 開始位置から消失(１回目)までの線の傾きを求める
                let s2f_slope: Double
                if ( (f_mp.x - s_mp.x) != 0 ) {
                    s2f_slope = (f_mp.y - s_mp.y) / (f_mp.x - s_mp.x)
                }
                else {
                    s2f_slope = 0
                }
                
                // 垂直二等分線の傾きを求める
                let p2r_slope: CLLocationDegrees
                if (s2f_slope != 0) {
                    p2r_slope = -1.0 / s2f_slope
                }
                else {
                    p2r_slope = 0.0
                }
#if DEBUG
    debug_f_mp = f_mp
    debug_p2r_slope = p2r_slope
#endif
                
                // 垂直二等分線の開始地点を求める
                let p_x1 = f_mp.x + (Double(AppPreference.GetHiddenRadius()) * MKMapPointsPerMeterAtLatitude(f_loc.latitude))
                let p_y1 = (p2r_slope * (p_x1 - f_mp.x)) + f_mp.y
                
                // 垂直二等分線の終了地点を求める
                let p_x2 = f_mp.x - (Double(AppPreference.GetHiddenRadius()) * MKMapPointsPerMeterAtLatitude(f_loc.latitude))
                let p_y2 = (p2r_slope * (p_x2 - f_mp.x)) + f_mp.y
                
                let loc1 = MKCoordinateForMapPoint(MKMapPoint(x: p_x1,y: p_y1))
                let loc2 = MKCoordinateForMapPoint(MKMapPoint(x: p_x2,y: p_y2))
                
                var perpendicularLocation:[CLLocationCoordinate2D] =
                    [CLLocationCoordinate2D(latitude: loc1.latitude, longitude: loc1.longitude),
                     CLLocationCoordinate2D(latitude: loc2.latitude, longitude: loc2.longitude)]
                
                // 開始位置から消失(１回目)までの線の垂直二等分線を描画
                secondSearchLine = MKPolyline(coordinates: &perpendicularLocation, count: 2)
                mapView.add(secondSearchLine)
                
                // **** 状態遷移 ****
                procState = PROC_STATE.WAIT_DISAPPEAR_SECOND
            }
            else {
                SimpleAlert.AlertMsg(pcv: self, msg: NSLocalizedString("MSG_LOCATION_ERROR", comment: ""))
            }
            
        default:
            break;
        }
    }

    /**
     [Event Driven] State: DisappearSecond
     - parameter event: Events that occurred
     - returns: nothing
     */
    private func proc_Evt_DisappearSecond(_ event: PROC_EVENT) {
        
         switch event {
         case PROC_EVENT.TAP_DISAPPEAR_SECOND:

            if (lcMgr.available == true) {
                
                var curLatitude = lcMgr.latitude
                var curLongitude = lcMgr.longitude
                
#if DEBUG
    let p_x1 = debug_f_mp.x + (100 * MKMapPointsPerMeterAtLatitude(curLatitude!))
    let p_y1 = (debug_p2r_slope * (p_x1 - debug_f_mp.x)) + debug_f_mp.y
    
    let loc = MKCoordinateForMapPoint(MKMapPoint(x: p_x1,y: p_y1))
    curLatitude = loc.latitude
    curLongitude = loc.longitude
#endif
                
                // *** 消失(２回目)の位置へピンを立てる ****
                annotationSecond.coordinate = CLLocationCoordinate2DMake(curLatitude!, curLongitude!)
                annotationSecond.title = NSLocalizedString("MSG_ANNOTATION_SECOND", comment: "")
                self.mapView.addAnnotation(annotationSecond)
                
                // *** 消失(１回目)から消失(２回目)までの線を描画し、その線分の垂直二等分線（ターゲットライン）を描画する ****
                var f2s_loc:[CLLocationCoordinate2D] =
                    [CLLocationCoordinate2D(latitude: annotationFirst.coordinate.latitude, longitude: annotationFirst.coordinate.longitude),
                     CLLocationCoordinate2D(latitude: annotationSecond.coordinate.latitude, longitude: annotationSecond.coordinate.longitude)]
                
                firstToSecondLine = MKPolyline(coordinates: &f2s_loc, count: 2)
                mapView.add(firstToSecondLine)
                
                let f_mp = MKMapPointForCoordinate(annotationFirst.coordinate)
                let s_mp = MKMapPointForCoordinate(annotationSecond.coordinate)
                
                let f_loc = MKCoordinateForMapPoint(MKMapPoint(x: f_mp.x,y: f_mp.y))
                
                // 消失(１回目)から消失(２回目)までの線の傾きを求める
                let f2s_slope: Double
                if ( (s_mp.x - f_mp.x) != 0 ) {
                    f2s_slope = (s_mp.y - f_mp.y) / (s_mp.x - f_mp.x)
                }
                else {
                    f2s_slope = 0
                }
                
                // 垂直二等分線の傾きを求める
                let p2r_slope: CLLocationDegrees
                if (f2s_slope != 0) {
                    p2r_slope = -1.0 / f2s_slope
                }
                else {
                    p2r_slope = 0.0
                }
                
#if DEBUG
    debug_f_mp = f_mp
    debug_p2r_slope = p2r_slope
#endif
                
                // 消失(１回目)から消失(２回目)までの中点を求める
                let c_x = ((s_mp.x - f_mp.x) / 2) + f_mp.x
                let c_y = ((s_mp.y - f_mp.y) / 2) + f_mp.y
                
                // 垂直二等分線の開始地点を求める
                let lineLength = ((Double(AppPreference.GetHiddenRadius()) * 1.2 ) * MKMapPointsPerMeterAtLatitude(f_loc.latitude))
                let t_x1 = c_x + lineLength
                let t_y1 = (p2r_slope * (t_x1 - c_x)) + c_y
                
                // 垂直二等分線の終了地点を求める
                let t_x2 = c_x - lineLength
                let t_y2 = (p2r_slope * (t_x2 - c_x)) + c_y
                
                let loc1 = MKCoordinateForMapPoint(MKMapPoint(x: t_x1,y: t_y1))
                let loc2 = MKCoordinateForMapPoint(MKMapPoint(x: t_x2,y: t_y2))
                
                var perpendicularLocation:[CLLocationCoordinate2D] =
                    [CLLocationCoordinate2D(latitude: loc1.latitude, longitude: loc1.longitude),
                     CLLocationCoordinate2D(latitude: loc2.latitude, longitude: loc2.longitude)]
                
                targetSearchLine = MKPolyline(coordinates: &perpendicularLocation, count: 2)
                mapView.add(targetSearchLine)
                
                // *** 状態遷移 ***
                procState = PROC_STATE.FINISH
            }
            else {
                SimpleAlert.AlertMsg(pcv: self, msg: NSLocalizedString("MSG_LOCATION_ERROR", comment: ""))
            }
            
         default:
            break;
         }
        
    }

    /**
     [Event Driven] State: Finish
     - parameter event: Events that occurred
     - returns: nothing
     */
    private func proc_Evt_Finish(_ event: PROC_EVENT) {
      // no action
    }

    /**
     [State Driven] Set guide text
     - parameter state: Occurred state
     - returns: nothing
     */
    private func proc_St_SetGuide(_ state: PROC_STATE){
        
        switch state {
        case PROC_STATE.WAIT_START:
            guideMessageLabel.text = NSLocalizedString("MSG_LABEL_GUIDE_IDLE", comment: "")
        case PROC_STATE.WAIT_DISAPPEAR_FIRST:
            guideMessageLabel.text = NSLocalizedString("MSG_LABEL_GUIDE_START", comment: "")
        case PROC_STATE.WAIT_DISAPPEAR_SECOND:
            guideMessageLabel.text = NSLocalizedString("MSG_LABEL_GUIDE_SEARCH", comment: "")
        case PROC_STATE.FINISH:
            guideMessageLabel.text = NSLocalizedString("MSG_LABEL_GUIDE_FINISH", comment: "")
        }
    }

    /**
     [State Driven] Set each view item
     - parameter state: Occurred state
     - returns: nothing
     */
    private func proc_St_SetViewItem(_ state: PROC_STATE){
        
        switch state {
        case PROC_STATE.WAIT_START:
            setButtonEnabled(button: searchStartButton, enabled: true)
            setButtonEnabled(button: disappearFirstTimeButton, enabled: false)
            setButtonEnabled(button: disappearSecondTimeButton, enabled: false)
        case PROC_STATE.WAIT_DISAPPEAR_FIRST:
            setButtonEnabled(button: searchStartButton, enabled: false)
            setButtonEnabled(button: disappearFirstTimeButton, enabled: true)
            setButtonEnabled(button: disappearSecondTimeButton, enabled: false)
        case PROC_STATE.WAIT_DISAPPEAR_SECOND:
            setButtonEnabled(button: searchStartButton, enabled: false)
            setButtonEnabled(button: disappearFirstTimeButton, enabled: false)
            setButtonEnabled(button: disappearSecondTimeButton, enabled: true)
        case PROC_STATE.FINISH:
            setButtonEnabled(button: searchStartButton, enabled: false)
            setButtonEnabled(button: disappearFirstTimeButton, enabled: false)
            setButtonEnabled(button: disappearSecondTimeButton, enabled: false)
        }
        
        // Always available
        resetButton.isEnabled = true
        pokegoAppbutton.isEnabled = true
    }
    
    /**
     [sub] Set Button enabled
     - parameter button: target button
     - parameter enabled: True or False
     - returns: nothing
     */
    private func setButtonEnabled( button :UIButton, enabled :Bool) {
        
        button.isEnabled = enabled
        
        if (enabled == true) {
            button.backgroundColor = UIColor.hexStr(hexStr: "004679", alpha: 1)
        }
        else {
            button.backgroundColor = UIColor.hexStr(hexStr: "9193a0", alpha: 1)
        }
    }
    

}

